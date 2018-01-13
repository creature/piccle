require 'flavour_saver'
require 'recursive-open-struct'

class Piccle::TemplateHelpers
  # Renders a partial template. Partial templates do NOT have their variables interpolated via Handlebars.
  def self.render_partial(template_name)
    slim_template = Tilt['slim'].new { File.read("templates/_#{template_name}.handlebars.slim") }
    slim_template.render
  end

  # Renders an entire template out
  def self.render(template_name, data = {})
    data = RecursiveOpenStruct.new(data, recurse_over_arrays: true)
    slim_template = Tilt['slim'].new { File.read("templates/#{template_name}.html.handlebars.slim") }
    template = Tilt['handlebars'].new { slim_template.render }

    template.render(data)
  end
end
