require 'handlebars'

class Piccle::TemplateHelpers
  # Renders a partial template. Partial templates do NOT have their variables interpolated via Handlebars.
  def self.render_partial(template_name, args = {})
    slim_template = Tilt['slim'].new { File.read("templates/_#{template_name}.handlebars.slim") }
    slim_template.render(Object.new, args)
  end

  # Renders an entire template out
  def self.render(template_name, data = {})
    options = { code_attr_delims: { '(' => ')', '[' => ']'}, attr_list_delims: { '(' => ')', '[' => ']' } }
    slim_template = Tilt['slim'].new(options) { File.read("templates/#{template_name}.html.handlebars.slim") }
    handlebars = Handlebars::Context.new
    template = handlebars.compile(slim_template.render)
    data['debug'] ||= []
    data.merge!({ site_metadata: site_metadata })
    template.call(data)
  end

  # Gets information about our site, used on pretty much every page.
  def self.site_metadata
    min_year = Piccle::Photo.earliest_photo_year
    max_year = Piccle::Photo.latest_photo_year
    copyright_year = if min_year == max_year
                      max_year
                    else
                      "#{min_year} – #{max_year}"
                    end

    OpenStruct.new(
      author_name: Piccle::AUTHOR_NAME,
      copyright_year: copyright_year
    )
  end
end
