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
      template_ready_metadata(metadata_of_type(:camera, photo_hash).first)
    end

    # Gets data suitable for constructing a "tag cloud" on a photo page.
    def keywords(photo_hash, selector)
      metadata_of_type(:keyword, photo_hash).map { |m| template_ready_metadata(m) }
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

    def metadata_of_type(type, photo_hash)
      metadata = @parser.metadata_for(photo_hash) || []
      metadata.select { |data| type == data[:type] }
    end

    # Process the given metadata into something more directly usable by the template.
    def template_ready_metadata(metadata)
      { friendly_name: metadata[:friendly_name], link: "#{metadata[:selector].join("/")}/index.html" } if metadata
    end

    def entries_for(data_hash, namespace)
      string_keys_only(data_hash).map do |k, v|
        { name: k, link: "#{namespace}/#{k}/index.html" }
      end
    end

    # TODO: duplicated from the parser. Can we centralise this somehow?
    def string_keys_only(data)
      data.select { |k, _| k.is_a? String }
    end

    # Proxy through to the template helper here.
    def include_prefix(selector)
      Piccle::TemplateHelpers.include_prefix(selector)
    end
  end
end
