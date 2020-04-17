# The "base parser" for Piccle. Repeatedly call parser.parse(Photo), and it pulls out the metadata necessary to generate pages.
# It'll figure out which details to pull out, links between individual photos, details like ordering, etc.
#
# Essentially, we end up building a big @data array that's got all the photo metadata, and the streams populate the various
# facets of the data. And then another module can render our site from this big specially-structured hash.
#
# Our hash looks like this:
# {
#   title: "Foo", # The title of this section
#   photos: { md5_string => Hash[photo_data] }, # Data needed to display
#   order: [md5_string, md5_string, md5_string], # An ordered list of hashes to display.
#   events: [ Hash[event_data] ] # Details about named events. These get special tiles on
#                                # the front page, but are implemented via a stream.
#

module Piccle
  class Parser
    attr_accessor :data
    attr_accessor :streams

    def initialize
      @data = {} # The extracted metadata that we'll use to generate our photo gallery.
      @photos = {} # An array of MD5 -> Photo object, in case we want to get back to them easily at some point.
      @streams = [] # Any extra processors that we want to use.
    end

    # Register a "stream", a thing that can extract extra data from a photo and add it to our data array, for later generation.
    def add_stream(stream)
      @streams << stream.new
    end

    # Do we have any photos in this parsed data yet?
    def empty?
      @data.empty?
    end

    # Parse a photo. Also passes it to any registered streams, which can subcategorise each photo into sections under its own namespace.
    def parse(photo)
      @photos[photo.md5] = photo
      @data[:photos] ||= {}

      @data[:photos][photo.md5] = { hash: photo.md5,
                                    file_name: photo.file_name,
                                    title: photo.title,
                                    photo_show_path: photo.photo_show_path,
                                    description: photo.description,
                                    width: photo.width,
                                    height: photo.height,
                                    taken_at: photo.taken_at,
                                    aperture: photo.aperture,
                                    shutter_speed: photo.friendly_shutter_speed,
                                    iso: photo.iso
      }

      @streams.each do |stream|
        to_add = stream.data_for(photo) if stream.respond_to?(:data_for)
        @data = merge_into(@data, to_add)
      end
    end

    # TODO: Asks each stream in turn to order its data. Call this after you've parsed all the photos, to generate an ordered list of photo hashes.
    # You can iterate over this list to display things.
    def order
      @data[:order] = @data[:photos].sort_by { |k, v| v[:taken_at] }.reverse.map { |a| a[0] }

      @streams.each do |stream|
        @data = stream.order(@data) if stream.respond_to?(:order)
      end
    end

    # Loads the event data from the EventStream. It also finds "sentinels", which are photos where we should display a special
    # tile beforehand to indicate the start/end of the event.
    def load_events
      order
      @data[:events] = Piccle::Streams::EventStream.new.events
      @data[:sentinels] = {}

      # Look at each 2 pics, try to figure out if there's an event that falls between them.
      @data[:order].each_cons(2) do |first_hash, second_hash|
        # TODO: Make all this way less error prone.
        first_photo_date = @data[:photos][first_hash][:taken_at].to_datetime
        second_photo_date = @data[:photos][second_hash][:taken_at].to_datetime

        if event = @data[:events].find { |ev| first_photo_date > ev[:from].to_datetime && second_photo_date < ev[:from].to_datetime }
          @data[:sentinels][second_hash] = { name: event[:name], type: :event_start }
        end

        if event = @data[:events].find { |ev| first_photo_date > ev[:to].to_datetime && second_photo_date < ev[:to].to_datetime }
          @data[:sentinels][second_hash] = { name: event[:name], type: :event_end }
        end
      end
    end

    # Gets a list of all subsections (ie. all the subindexes that we should render).
    # It's an array of hash keys, suitable for passing via @data.dig(*keys).
    def subsections
      previous_size = 0
      subsection_list = faceted_data.keys.map { |el| [el] }
      size = subsection_list.count

      # Find all the string keys in our data.
      loop do
        subsection_list.each do |key_path|
          new_keys = string_keys_only(@data.dig(*key_path)).keys
          new_keys.each { |k| subsection_list << key_path + [k] }
        end

        # Clean up our state - remove dupes, update counts.
        subsection_list.uniq!
        previous_size = size
        size = subsection_list.count
        break if previous_size == size
      end

      subsection_list
    end

    # Get photo hashes in a given subsection, given a diggable path.
    def subsection_photo_hashes(subsection_path)
      @data.dig(*subsection_path).fetch(:photos, [])
    end

    # Gets the actual photo objects for a given subsection.
    def subsection_photos(subsection_path)
      subsection_photo_hashes(subsection_path).map { |hash| [hash, @data[:photos][hash]] }.to_h
    end

    # Given an MD5 hash, returns an array of arrays. Each array is a set of strings that, combined with the MD5, gives a link to the photo.
    # So for instance, with a date stream parser, if a photo was taken on 2016-04-19 you'll get back:
    # [["by-date", "2016"], ["by-date", "2016", "4"], ["by-date", "2016", "4", "19"]]
    # And you could use that to generate a links akin to /by-date/2016/4/19/abcdef1234567890.html.
    def links_for(md5)
      # Return each key that includes the photos.
      subsections.select { |path| @data.dig(*path).fetch(:photos, []).include?(md5) }
    end

    # Gets a (currently top-level only) navigation structure. All entries have at least one photo.
    def navigation
      faceted_data.map do |k, v|
        { friendly_name: v[:friendly_name],
          entries: entries_for(v, k)
        }
      end
    end

    # Given a photo hash, and a substream selector (which may be omitted, for the main list of photos),
    # returns an array with *up to* 5 previous/next photos, as well as this image. It's ideal for rendering small
    # strips of neighbouring images.
    def substream_hashes_for(hash, selector = [])
      relevant_hashes = (@data.dig(*selector, :photos) || {})
      relevant_hashes = relevant_hashes.keys if relevant_hashes.respond_to?(:keys)
      if photo_index = relevant_hashes.find_index(hash)
        before_index = [0, photo_index-5].max
        after_index = [photo_index + 5, relevant_hashes.length - 1].min
        relevant_hashes[before_index..after_index]
      else
        []
      end
    end

    # Returns a substream hash. This is a bundle of data suitable for rendering a navigation strip within this stream.
    # It includes a title for the substream, previous/next photos where applicable (ie. for nav arrows), and a set of
    # photos including the current photo.
    def substream_for(hash, selector = [])
      photo_hashes = substream_hashes_for(hash, selector)
      if photo_hashes.any?
        substream = {}
        photo_i = photo_hashes.find_index(hash)
        substream[:title] = @data.dig(*selector, :friendly_name)
        substream[:photos] = photo_hashes.map { |h| @data[:photos][h] }
        substream[:previous] = @data[:photos][photo_hashes[photo_i - 1]] if photo_i > 0
        substream[:next] = @data[:photos][photo_hashes[photo_i + 1]] if photo_i < photo_hashes.length - 1
        substream
      else
        nil
      end
    end

    # Accessor for the photo hashes.
    def photo_hashes
      @photos.keys
    end

    protected

    # Gets the data that we faceted - the things broken down by stream.
    def faceted_data
      string_keys_only(@data)
    end

    def string_keys_only(data)
      data.select { |k, _| k.is_a? String }
    end

    def entries_for(data_hash, namespace)
      string_keys_only(data_hash).map do |k, v|
        { name: k, link: "#{namespace}/#{k}/index.html" }
      end
    end

    def merge_into(destination, source)
      # If the source has a photos key, make sure one exists in the destination, and then append the source's contents.
      if source.key?(:photos)
        destination[:photos] ||= []
        destination[:photos] += source[:photos]
      end

      # For all the other keys, see if the destination has them. If it does, combine them using OURSELF. Otherwise, just set it to our version.
      source.keys.each do |key|
        next if :photos == key
        if destination.key?(key) && destination[key].is_a?(Hash)
          destination[key] = merge_into(destination[key], source[key])

        else
          destination[key] = source[key]
        end
      end

      destination
    end
  end
end
