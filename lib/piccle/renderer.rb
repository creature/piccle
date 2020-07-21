module Piccle
  # Renders a bunch of pages, based on the hash data loaded by the given parser.
  class Renderer
    def initialize(parser)
      @parser = parser
      @extractor = Piccle::Extractor.new(parser)
    end

    # Given an array that contains a path (not including a :photos key), get that photo
    # data and render an index page using the :photos data found at that location.
    #
    # For instance, if selector was ["by-date", "2015"] you'd get an index page of photos
    # for 2015 based on the data held by the parser.
    def render_index(selector)
      template_vars = {
        photos: @parser.subsection_photos(selector),
        sentinels: [],
        navigation: render_nav(selector),
        selector: selector,
        selector_path: "#{selector.join('/')}/",
        breadcrumbs: @extractor.breadcrumbs_for(selector),
        include_prefix: Piccle::TemplateHelpers.include_prefix(selector)
      }

      Piccle::TemplateHelpers.render("index", template_vars)
    end

    # Renders the "main" index – the front page of our site.
    def render_main_index
      photos = @parser.data[:photos]
      debug = if Piccle::DEBUG
                debug = [{ title: "Number of photos", value: photos.length }]
              end
      Piccle::TemplateHelpers.render("index", photos: photos, sentinels: @parser.data[:sentinels], navigation: render_nav, debug: debug)
    end

    # Render a page for a specific photo.
    def render_photo(hash, selector=[])
      photo_data = @parser.data[:photos][hash]
      substreams = [@parser.substream_for(hash)] + @parser.links_for(hash).map { |selector| @parser.interesting_substream_for(hash, selector) }.compact


      template_vars = {
        photo: photo_data,
        selector: selector,
        selector_path: selector.any? ? "#{selector.join('/')}/" : "",
        breadcrumbs: @extractor.breadcrumbs_for(selector),
        substreams: substreams.select { |stream| stream[:photos].length > 1 },
        camera_link: @extractor.camera_link(hash),
        keywords: @extractor.keywords(hash),
        day_link: @extractor.day_link(hash),
        month_link: @extractor.month_link(hash),
        year_link: @extractor.year_link(hash),
        prev_link: @extractor.prev_link(hash, selector),
        next_link: @extractor.next_link(hash, selector),
        include_prefix: Piccle::TemplateHelpers.include_prefix(selector),
        canonical: "photos/#{hash}.html" # TODO: Other paths live in piccle.rake. Why's this one here?
      }

      photo_title = photo_data[:title] || ""
      photo_title = "Photo" if photo_title.empty?
      template_vars[:breadcrumbs] << { friendly_name: photo_title } if selector.any?

      Piccle::TemplateHelpers.render("show", template_vars)
    end

    protected

    # Gets the navigation info from the parser data.
    def render_nav(selector = [])
      template_vars = { nav_items: @extractor.navigation, include_prefix: Piccle::TemplateHelpers.include_prefix(selector) }
      Piccle::TemplateHelpers.render("navigation", template_vars)
    end
  end
end
