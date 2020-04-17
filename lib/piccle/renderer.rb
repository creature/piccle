module Piccle
  # Renders a bunch of pages, based on the hash data loaded by the given parser.
  class Renderer
    def initialize(parser)
      @parser = parser
    end

    # Given an array that contains a path (not including a :photos key), get that photo
    # data and render an index page using the :photos data found at that location.
    #
    # For instance, if selector was ["by-date", "2015"] you'd get an index page of photos
    # for 2015 based on the data held by the parser.
    def render_index(selector)
      template_vars = {
        photos: @parser.subsection_photos(selector),
        order: @parser.data[:order],
        sentinels: [],
        navigation: render_nav(selector),
        selector: selector,
        include_prefix: include_prefix(selector)
      }

      Piccle::TemplateHelpers.render("index", template_vars)
    end

    # Renders the "main" index – the front page of our site.
    def render_main_index
      photos = @parser.data[:photos]
      debug = if Piccle::DEBUG
                debug = [{ title: "Number of photos", value: photos.length }]
              end
      Piccle::TemplateHelpers.render("index", photos: photos, order: @parser.data[:order], sentinels: @parser.data[:sentinels], navigation: render_nav, debug: debug)
    end

    # Render a page for a specific photo.
    def render_photo(hash, selector=[])
      photo_data = @parser.data[:photos][hash]
      substreams = [@parser.substream_for(hash)] + @parser.links_for(hash).map { |selector| @parser.substream_for(hash, selector) }

      template_vars = {
        photo: photo_data,
        selector: selector,
        substreams: substreams.select { |stream| stream.length > 1 },
        canonical: "photos/#{hash}.html" # TODO: Other paths live in piccle.rake. Why's this one here?
      }
      template_vars[:include_prefix] = include_prefix(selector) if selector.any?

      Piccle::TemplateHelpers.render("show", template_vars)
    end

    protected

    # Gets the navigation info from the parser data.
    def render_nav(selector = [])
      template_vars = { nav_items: @parser.navigation }
      template_vars[:include_prefix] = include_prefix(selector) if selector.any?
      Piccle::TemplateHelpers.render("navigation", template_vars)
    end

    # Given a selector array, convert it into a file path prefix.
    # eg. ["by-date", "2017", "03"] → "../../../"
    def include_prefix(selector)
      "#{(['..'] * selector.length).join('/')}/"
    end
  end
end
