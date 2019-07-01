require 'json'
require 'yaml'

# A special-case stream that handles named "events". You can define details in events.yaml - with things like a name,
# dates, and whether it should be collapsed or not on the front page.

class Piccle::Streams::EventStream
  def namespace
    :events
  end

  def initialize
    @events = []
    @loaded = false
  end

  def events
    unless @loaded
      if File.exists?(Piccle::EVENT_YAML_FILE)
        @events = YAML.load_file(Piccle::EVENT_YAML_FILE)
        @events.map! do |event| # Make keys into symbols.
          event.map { |k, v| [k.to_sym, v] }.to_h
        end
      end
      @loaded = true
    end
    @events
  end
end
