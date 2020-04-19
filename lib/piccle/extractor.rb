# A companion class for the parser. The parser extracts data out from each photo, and keeps it in a data structure.
# It also provides some "primitives" for slicing and dicing that data.
#
# The extractor is in charge of turning that into something closer to "human readable". Something you can use in
# a template.

module Piccle
  class Extractor
    def initialize(parser)
      @parser = parser
    end

    # Gets data for constructing a camera link for a particular photo.
    def camera_link(photo_hash, selector)
      { friendly_name: "Camera", link: "Hi" }
    end

    # Gets data suitable for constructing a "tag cloud" on a photo page.
    def keywords(photo_hash, selector)
    end

    # Given a selector array, convert it into a file path prefix.
    # eg. ["by-date", "2017", "03"] → "../../../"
    def include_prefix(selector)
      if selector.any?
        "#{(['..'] * selector.length).join('/')}/"
      else
        ""
      end
    end

    # Gets a (currently top-level only) navigation structure. All entries have at least one photo.
    def navigation
      @parser.faceted_data.map do |k, v|
        { friendly_name: v[:friendly_name],
          entries: entries_for(v, k)
        }
      end
    end

    protected

    def entries_for(data_hash, namespace)
      string_keys_only(data_hash).map do |k, v|
        { name: k, link: "#{namespace}/#{k}/index.html" }
      end
    end

    # TODO: duplicated from the parser. Can we centralise this somehow?
    def string_keys_only(data)
      data.select { |k, _| k.is_a? String }
    end
  end
end
