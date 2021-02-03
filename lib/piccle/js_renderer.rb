# Render using a NodeJS helper program. The Handlebars.rb bindings are tied to an old version of libv8; they render
# REALLY slowly as a result.
# This renderer calls out to a NodeJS helper program instead - so all the templating is handled in JavaScript.
module Piccle
  class JsRenderer < Renderer
    def initialize(*args)
      @renderer = IO.popen(["node", "js-renderer/renderer.js", Piccle.config.output_dir], "r+")
      super(*args)
    end

    def render_main_index
      template_vars = paginate(render_main_index_template_vars)
      template_vars.map { |page_template_vars| call_nodejs("index", page_template_vars) }
    end

    def render_index(selector)
      template_vars = paginate(render_index_template_vars(selector))
      template_vars.map { |page_template_vars| call_nodejs("index", page_template_vars) }
    end

    def render_photo(hash, selector = [])
      call_nodejs("show", render_photo_template_vars(hash, selector))
    end

    protected

    def call_nodejs(template, template_vars)
      @renderer.write("render_#{template}\n")
      @renderer.write("#{JSON.dump(template_vars)}\n")
      buffer = ""
      loop do
        line = @renderer.readline
        break if line.strip == "\x1C"
        buffer += line
      end
      buffer
    end
  end
end
