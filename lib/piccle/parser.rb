# The "base parser" for Piccle. Repeatedly call parser.parse(Photo), and it pulls out the metadata necessary to generate pages.
# It'll figure out which details to pull out, links between individual photos, details like ordering, etc. #

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

    # Parse a photo. Also parses it to any registered streams,
    def parse(photo)
      @photos[photo.md5] = photo
      @data[:photos] ||= {}

      @data[:photos][photo.md5] = { title: photo.title, description: photo.description, width: photo.width, height: photo.height, taken_at: photo.taken_at }

      @streams.each do |stream|
        to_add = stream.data_for(photo)
        @data = merge_into(@data, to_add)
      end
    end

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
