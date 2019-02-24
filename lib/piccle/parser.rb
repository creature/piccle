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
      @streams << stream
    end

    # Do we have any photos in this parsed data yet?
    def empty?
      @data.empty?
    end

    # Parse a photo. Also parses it to any registered streams,
    def parse(photo)
      @data[:photos] ||= {}

      @data[:photos][photo.md5] = { title: photo.title, description: photo.description, width: photo.width, height: photo.height, taken_at: photo.taken_at }
      @photos[photo.md5] = photo
    end

    def links_for(md5)
      []
    end
  end
end
