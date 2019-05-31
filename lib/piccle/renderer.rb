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


    end

    # Renders the "main" index – the front page of our site.
    def render_main_index
      photos = @parser.data[:photos]
      puts "I have #{photos.length} photos"
      site_metadata = Piccle::TemplateHelpers.site_metadata
      Piccle::TemplateHelpers.render("index", photos: photos, site_metadata: site_metadata)
    end
  end
end
