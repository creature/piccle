# The "base parser" for Piccle. Repeatedly call parser.parse(Photo), and it pulls out the metadata necessary to generate pages.
# It'll figure out which details to pull out, links between individual photos, details like ordering, etc.
#
# Essentially, we end up building a big @data array that's got all the photo metadata, and the streams populate the various
# facets of the data. And then another module can render our site from this big specially-structured hash.

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

      @data[:photos][photo.md5] = { title: photo.title, description: photo.description, width: photo.width, height: photo.height, taken_at: photo.taken_at }

      @streams.each do |stream|
        to_add = stream.data_for(photo)
        @data = merge_into(@data, to_add)
      end
    end

    # Asks each stream in turn to order its data. Call this after you've parsed all the photos, to generate an ordered list of photos
    # (so you can generate sensible previous/next links). TODO.
    def order!

    end

    # Given an MD5 hash, returns an array of arrays. Each array is a set of strings that, combined with the MD5, gives a link to the photo.
    # So for instance, with a date stream parser, if a photo was taken on 2016-04-19 you'll get back:
    # [["by-date", "2016"], ["by-date", "2016", "4"], ["by-date", "2016", "4", "19"]]
    # And you could use that to generate a links akin to /by-date/2016/4/19/abcdef1234567890.html.
    def links_for(md5)
      []
    end

    protected

    def merge_into(destination, source)
      # If the source has a photos key, make sure one exists in the destination, and then append the source's contents.
      if source.has_key? :photos
        destination[:photos] ||= []
        destination[:photos] += source[:photos]
      end

      # For all the other keys, see if the destination has them. If it does, combine them using OURSELF. Otherwise, just set it to our version.
      source.keys.each do |key|
        next if :photos == key
        if destination.has_key? key
          destination[key] = merge_into(destination[key], source[key])
        else
          destination[key] = source[key]
        end
      end

      destination
    end
  end
end
