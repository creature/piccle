require 'cgi'
require 'handlebars'

# Rendering functions for templates.
# * For most files, we use Slim to render a Handlebars template (ie. HTML with embedded Handlebars). Handlebars then
#   generates the final output. This lets us use the same templates for backend and frontend rendering.
# * Partials don't have variable interpolation, because they're rendered inline into the main template. Their variables
#   will be interpolated when the overall template is rendered.
# * RSS feeds are generated via Slim only, as we don't need to generate those server-side.
#
# We don't cache Handlebars templates, because it actually results in WORSE performance than compiling a fresh instance
# each time.

class Piccle::TemplateHelpers
  @@handlebars = nil
  @@slim_pages = {}
  @@slim_partials = {}

  # Renders a partial template. Partial templates do NOT have their variables interpolated via Handlebars.
  def self.render_partial(template_name, args = {})
    @@slim_partials[template_name] ||= Tilt['slim'].new { File.read(Piccle.config.gem_root_join("templates/_#{template_name}.handlebars.slim")) }
    @@slim_partials[template_name].render(Object.new, args)
  end

  # Renders an entire template out
  def self.render(template_name, data = {})
    options = { code_attr_delims: { '(' => ')', '[' => ']'}, attr_list_delims: { '(' => ')', '[' => ']' } }
    @@slim_pages[template_name] ||= Tilt['slim'].new(options) { File.read(Piccle.config.gem_root_join("templates/#{template_name}.html.handlebars.slim")) }.render
    template = handlebars.compile(@@slim_pages[template_name])
    template.call(data)
  end

  def self.render_rss(template_name, data = {})
    @@slim_pages["rss_#{template_name}"] ||= Tilt['slim'].new { File.read(Piccle.config.gem_root_join("templates/#{template_name}.atom.slim")) }
    @@slim_pages["rss_#{template_name}"].render(Object.new, data)
  end

  # Gets a Handlebars version of the template. No variable replacement!
  def self.compile_template(name)
    slim_template = Tilt['slim'].new { File.read(Piccle.config.gem_root_join("templates/#{name}.html.handlebars.slim")) }
    slim_template.render(Object.new, {})
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

  # Given a block of content, escape its HTML.
  def self.escape_html(&block)
    CGI::escape_html(yield)
  end

  protected

  def self.handlebars
    unless @@handlebars
      @@handlebars = Handlebars::Context.new
      @@handlebars.register_helper(:ifEqual) do |context, arg1, arg2, block|
        if arg1 == arg2
          block.fn(context)
        else
          block.inverse(context)
        end
      end

      @@handlebars.register_helper(:join) do |context, arg1, arg2, block|
        arg1.join(arg2)
      end
    end
    @@handlebars
  end
end
