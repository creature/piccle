# The "base parser" for Piccle. Repeatedly call parser.parse(Photo), and it pulls out the metadata necessary to generate pages.
# It'll figure out which details to pull out, links between individual photos, details like ordering, etc. #

module Piccle
  class Parser
    attr_accessor :data

    def initialize
      @data = {}
    end

    def empty?
      @data.empty?
    end

    def parse(photo)
      @data[:photos] ||= {}

      @data[:photos][:md5] = photo.md5
    end
  end
end
