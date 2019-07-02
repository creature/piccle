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
        to_add = stream.data_for(photo)
        @data = merge_into(@data, to_add)
      end
    end

    # Asks each stream in turn to order its data. Call this after you've parsed all the photos, to generate an ordered list of photo hashes.
    # You can iterate over this list to display things.
    def order
      @data[:order] = @data[:photos].sort_by { |k, v| v[:taken_at] }.reverse.map { |a| a[0] }
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
      puts @data[:sentinels].inspect
    end

    # Given an MD5 hash, returns an array of arrays. Each array is a set of strings that, combined with the MD5, gives a link to the photo.
    # So for instance, with a date stream parser, if a photo was taken on 2016-04-19 you'll get back:
    # [["by-date", "2016"], ["by-date", "2016", "4"], ["by-date", "2016", "4", "19"]]
    # And you could use that to generate a links akin to /by-date/2016/4/19/abcdef1234567890.html.
    def links_for(md5)
      links = []
      prefix = []
      faceted_data.each do |k, v|
        links << dig_for_links_for(prefix, md5, v)
      end

      links
    end


    def navigation
      faceted_data.map do |k, v|
        { friendly_name: v[:friendly_name],
          entries: [{ name: "Fuji X100F", link: "by-camera/fuji-x100f" }, { name: "Canon 350D", link: "by-camera/canon-350d" }],
        }
      end
    end

    # Accessor for the photo hashes.
    def photo_hashes
      @photos.keys
    end

    protected

    # Gets the data that we faceted - the things broken down by stream.
    def faceted_data
      @data.select { |k, _| k.is_a? String } # Only look at data from streams
    end

    # Recursive function that digs into a subtree of our data. If we find the supplied MD5, we return the prefix
    # array plus our found element. If we don't, we look in the subtree for it.
    def dig_for_links_for(prefix, md5, subtree)
        prefix if subtree.dig(:photos, md5)
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
