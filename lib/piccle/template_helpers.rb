class Piccle::TemplateHelpers
  def self.render_partial(template_name, data)
    self.render_template("_#{template_name}.html.handlebars.slim", data)
  end

  # Renders an entire template out
  def self.render(template_name, data)
    self.render_template("#{template_name}.html.handlebars.slim", data)
  end

  private

  def self.render_template(template_name, data)
    data = OpenStruct.new(data)
    slim_template = Tilt['slim'].new { File.read("templates/#{template_name}") }
    template = Tilt['handlebars'].new { slim_template.render }

    template.render(data)
  end
end
