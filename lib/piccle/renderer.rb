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
      template_vars = paginate(render_index_template_vars(selector))
      template_vars.map { |page_template_vars| Piccle::TemplateHelpers.render("index", page_template_vars) }
    end

    # Renders the "main" index – the front page of our site.
    def render_main_index
      template_vars = paginate(render_main_index_template_vars)
      template_vars.map { |page_template_vars| Piccle::TemplateHelpers.render("index", page_template_vars) }
    end

    # Renders an Atom feed of the given subsection.
    def render_feed(selector = [])
      photos = @parser.subsection_photos(selector).sort_by { |k, p| p[:created_at] }.reverse
      escaped_selector = selector.map { |s| CGI::escape(s) }

      template_vars = {
        photos: photos,
        joined_selector: "/#{escaped_selector.join("/")}/",
        feed_update_time: photos.map { |k, v| v[:created_at] }.max,
        selector: selector,
        site_metadata: site_metadata
      }

      Piccle::TemplateHelpers.render_rss("feed", template_vars)
    end

    # Render a page for a specific photo.
    def render_photo(hash, selector=[])
      Piccle::TemplateHelpers.render("show", render_photo_template_vars(hash, selector))
    end

    # What should we call this index page? The first page is "index" (ie. index.html), later ones have a number
    # (eg. "index-02"). NB! Our indexes are 0 based, but our pages are 1 based. (0 → index, 1 → index-02, 2 → index-03).
    def index_page_name_for(index)
      index.zero? ? "index" : "index-#{sprintf("%02d", index + 1)}"
    end

    protected

    # Returns all the data we pass into the main index to render.
    def render_main_index_template_vars
      template_vars = {
        photos: @extractor.main_index_photos,
        event_starts: @parser.data[:event_starts],
        event_ends: @parser.data[:event_ends],
        nav_items: @extractor.navigation,
        site_metadata: site_metadata
      }

      if Piccle.config.open_graph?
        width, height = Piccle::QuiltGenerator.dimensions_for(@parser.data[:photos].length)
        template_vars[:open_graph] = open_graph_for(title: site_title(),
                                                    description: "A gallery of photos by #{Piccle.config.author_name}",
                                                    image_url: "#{Piccle.config.home_url}quilt.jpg",
                                                    image_alt: "A quilt of the most recent images in this gallery.",
                                                    width: width,
                                                    height: height,
                                                    page_url: Piccle.config.home_url)
      end
      template_vars
    end

    # Returns all the data we pass into a template for rendering an index page, as a hash.
    def render_index_template_vars(selector)
      breadcrumbs = @extractor.breadcrumbs_for(selector)
      selector_path = "#{selector.join('/')}/"
      template_vars = {
        photos: @parser.subsection_photos(selector),
        event_starts: [],
        event_ends: [],
        nav_items: @extractor.navigation,
        selector: selector,
        selector_path: selector_path,
        breadcrumbs: breadcrumbs,
        site_url: Piccle.config.home_url,
        include_prefix: Piccle::TemplateHelpers.include_prefix(selector),
        site_metadata: site_metadata
      }

      if Piccle.config.open_graph?
        width, height = Piccle::QuiltGenerator.dimensions_for(@parser.subsection_photo_hashes(selector).length)
        template_vars[:open_graph] = open_graph_for(title: site_title(breadcrumbs),
                                                    description: "A gallery of photos by #{Piccle.config.author_name}",
                                                    image_url: "#{Piccle.config.home_url}#{selector_path}quilt.jpg",
                                                    image_alt: "A quilt of the most recent images in this gallery.",
                                                    width: width,
                                                    height: height,
                                                    page_url: "#{Piccle.config.home_url}#{selector_path}")
      end

      template_vars
    end

    # Given a set of template variables, paginate them. Specifically:
    # - Take the :photos key, and break it into chunks
    # - Add a :pagination key with details of all the pages
    # - Returns an array of template vars.
    def paginate(template_vars)
      slices = template_vars[:photos].each_slice(100)
      pages = (0...slices.count).map { |i| { label: i + 1, page_name: index_page_name_for(i) } }

      slices.map.with_index do |slice, i|
        pages_with_current = pages.map.with_index { |page, index| page.merge(is_current: (i == index)) }

        # TODO: add prev_link and next_link, if present.
        template_vars.merge(photos: slice.to_h,
                            pagination: {
                              page_name: index_page_name_for(i),
                              pages: pages_with_current,
                              is_first_page: i.zero?,
                              is_last_page: i == slices.count - 1,
                              previous_page_name: index_page_name_for(i-1),
                              next_page_name: index_page_name_for(i+1),
                              total_pages: slices.count
                            })
      end
    end

    # Returns all the template vars we use to render a photo page.
    def render_photo_template_vars(hash, selector)
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
        city_link: @extractor.city_link(hash),
        state_link: @extractor.state_link(hash),
        country_link: @extractor.country_link(hash),
        prev_link: @extractor.prev_link(hash, selector),
        next_link: @extractor.next_link(hash, selector),
        include_prefix: Piccle::TemplateHelpers.include_prefix(selector),
        canonical: "photos/#{hash}.html", # TODO: Other paths live in piccle.rake. Why's this one here?
        site_metadata: site_metadata
      }

      photo_title = photo_data[:title] || ""
      photo_title = "Photo" if photo_title.empty?
      template_vars[:breadcrumbs] << { friendly_name: photo_title } if selector.any?

      if Piccle.config.open_graph?
        template_vars[:open_graph] = open_graph_for(title: photo_data[:title] || "A photo by #{Piccle.config.author_name}",
                                                    description: photo_data[:description],
                                                    image_url: "#{Piccle.config.home_url}images/photos/#{hash}.#{photo_data[:file_name]}",
                                                    width: photo_data[:width],
                                                    height: photo_data[:height],
                                                    page_url: "#{Piccle.config.home_url}/#{hash}.html")
      end

      template_vars
    end

    # Gets information about our site, used on pretty much every page.
    def site_metadata
      unless @cached_site_metadata
        min_year = Piccle::Photo.earliest_photo_year
        max_year = Piccle::Photo.latest_photo_year
        copyright_year = if min_year == max_year
                          max_year
                        else
                          "#{min_year} – #{max_year}"
                        end

        @cached_site_metadata = { author_name: Piccle.config.author_name, copyright_year: copyright_year }
      end
      @cached_site_metadata
    end

    # Returns a hash of open graph data based on the parameters passed in.
    def open_graph_for(title: nil, description: nil, image_url: nil, image_alt: nil, width: nil, height: nil, page_url: nil)
      open_graph = { title: title, url: page_url, image: { width: width, height: height, url: image_url } }
      open_graph[:image][:image_alt] = image_alt if image_alt
      open_graph[:description] = description if description
      open_graph
    end

    # Returns a human-readable title for this site.
    def site_title(breadcrumbs = [])
      title = "Photography by #{Piccle.config.author_name}"
      if breadcrumbs.any?
        title += " - " + breadcrumbs.map { |b| b[:friendly_name] }.join(" - ")
      end
      title
    end
  end
end
