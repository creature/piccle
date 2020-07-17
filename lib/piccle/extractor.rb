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
    def camera_link(photo_hash)
      template_ready_metadata(metadata_of_type(:camera, photo_hash).first)
    end

    # Gets data suitable for constructing a "tag cloud" on a photo page.
    def keywords(photo_hash)
      metadata_of_type(:keyword, photo_hash).map { |m| template_ready_metadata(m) }
    end

    def day_link(photo_hash)
      template_ready_metadata(metadata_of_type(:date_day, photo_hash).first)
    end

    def month_link(photo_hash)
      template_ready_metadata(metadata_of_type(:date_month, photo_hash).first)
    end

    def year_link(photo_hash)
      template_ready_metadata(metadata_of_type(:date_year, photo_hash).first)
    end

    # Given that we're in the stream described by selector, what's the link to the previous photo?
    # If there's no selector, we look at all photos. Returns nil if there is no photo before this one.
    def prev_link(photo_hash, selector)
      _first, *rest = *@parser.substream_hashes_for(photo_hash, selector)

      if index = rest.index(photo_hash)
        "#{(selector + [rest[index-1]]).join("/")}.html"
      else
        nil
      end
    end

    # Given that we're in the stream described by selector, what's the link to the next photo?
    # If there's no selector, we look at all photos. Returns nil if there is no photo after this one.
    def next_link(photo_hash, selector)
      hashes = @parser.substream_hashes_for(photo_hash, selector)

      index = hashes.index(photo_hash)
      if index && index < (hashes.length - 1)
        "#{(selector + [hashes[index + 1]]).join("/")}.html"
      else
        nil
      end
    end

    # Gets a (currently top-level only) navigation structure. All entries have at least one photo.
    def navigation
      navigation_entries = @parser.faceted_data.map do |k, v|
                             { friendly_name: v[:friendly_name],
                               entries: entries_for(v, k)
                             }
                           end
      # A hack, to only show keywords that have more than one image.
      navigation_entries.each do |nav_entry|
        nav_entry[:entries].keep_if { |entry| entry[:photo_count] > 1 } if "By Topic" == nav_entry[:friendly_name]
      end
    end

    # Given a selector, generate breadcrumbs data for it. Basically link up all the elements except the first
    # (which is a namespace, and linkless).
    def breadcrumbs_for(selector)
      result = []
      if selector.first
        result << { friendly_name: @parser.friendly_name_for([selector.first]) }
      end
      (1..selector.length-1).map do |i|
        result << { friendly_name: @parser.friendly_name_for(selector[0..i]), link: "#{selector[0..i].join("/")}/index.html" }
      end

      result
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
        { name: k, link: "#{namespace}/#{k}/index.html", photo_count: v[:photos].length }
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
