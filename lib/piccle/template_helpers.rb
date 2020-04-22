require 'handlebars'

class Piccle::TemplateHelpers
  @@handlebars = nil
  @@slim_pages = {}
  @@slim_partials = {}

  # Renders a partial template. Partial templates do NOT have their variables interpolated via Handlebars.
  def self.render_partial(template_name, args = {})
    @@slim_partials[template_name] ||= Tilt['slim'].new { File.read("templates/_#{template_name}.handlebars.slim") }
    @@slim_partials[template_name].render(Object.new, args)
  end

  # Renders an entire template out
  def self.render(template_name, data = {})
    options = { code_attr_delims: { '(' => ')', '[' => ']'}, attr_list_delims: { '(' => ')', '[' => ']' } }
    @@slim_pages[template_name] ||= Tilt['slim'].new(options) { File.read("templates/#{template_name}.html.handlebars.slim") }
    template = handlebars.compile(@@slim_pages[template_name].render)
    data['debug'] ||= []
    data.merge!({ site_metadata: site_metadata })
    template.call(data)
  end

  # Gets a Handlebars version of the template. No variable replacement!
  def self.compile_template(name)
    slim_template = Tilt['slim'].new { File.read("templates/#{name}.html.handlebars.slim") }
    slim_template.render(Object.new, {})
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

  # Given a "selector" (an array of string path components), returns an "include prefix" (a relative path that
  # gets us back to the top level).
  # eg. ["by-date", "2017", "03"] → "../../../"
  def self.include_prefix(selector)
    if selector.any?
      "#{(['..'] * selector.length).join('/')}/"
    else
      ""
    end
  end

  protected

  def self.handlebars
    unless @@handlebars
      @@handlebars = Handlebars::Context.new
      @@handlebars.register_helper(:ifEqual) do |context, arg1, arg2, block|
        if arg1 == arg2
          block.fn(context)
        end
      end
    end
    @@handlebars
  end
end
