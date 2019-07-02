require 'json'
require 'yaml'

# A special-case stream that handles named "events". You can define details in events.yaml - with things like a name,
# dates, and whether it should be collapsed or not on the front page.

class Piccle::Streams::EventStream
  attr_accessor :events

  def namespace
    :events
  end

  def initialize
    if File.exists?(Piccle::EVENT_YAML_FILE)
      @events = YAML.load_file(Piccle::EVENT_YAML_FILE)
      @events.map! do |event| # Make keys into symbols.
        event.map { |k, v| [k.to_sym, v] }.to_h
      end
    end
  end

  def data_for(photo)
  end
end
