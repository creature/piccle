# Render using a NodeJS helper program. The Handlebars.rb bindings are tied to an old version of libv8; they render
# REALLY slowly as a result.
# This renderer calls out to a NodeJS helper program instead - so all the templating is handled in JavaScript.
module Piccle
  class JsRenderer < Renderer

    def render_index(selector)
      call_nodejs("index", render_index_template_vars(selector))
    end

    def render_photo(hash, selector = [])
      call_nodejs("show", render_photo_template_vars(hash, selector))
    end

    protected

    def call_nodejs(template, template_vars)
      IO.popen("node js-renderer/renderer.js #{template}", "r+") do |io|
        JSON.dump(template_vars, io)
        io.close_write

        output = io.readlines
        return output.join
      end
    end
  end
end
