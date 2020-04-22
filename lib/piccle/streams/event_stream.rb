require 'json'
require 'yaml'

# A special-case stream that handles named "events". You can define details in events.yaml - with things like a name,
# dates, and whether it should be collapsed or not on the front page.

class Piccle::Streams::EventStream
  attr_accessor :events

  def namespace
    "by-event"
  end

  def initialize
    if File.exists?(Piccle::EVENT_YAML_FILE)
      @events = YAML.load_file(Piccle::EVENT_YAML_FILE)
      @events.map! do |event| # Make keys into symbols.
        event = event.map { |k, v| [k.to_sym, v] }.to_h
        event[:from] = event[:from].to_datetime
        event[:to] = event[:to].to_datetime
        event
      end
    end
  end

  def data_for(photo)
    if photo.taken_at
      relevant_events = @events.select { |ev| photo.taken_at.to_datetime >= ev[:from] && photo.taken_at.to_datetime <= ev[:to] }
      result = { namespace => { friendly_name: "By Event", interesting: true }}
      relevant_events.each do |ev|
        result[namespace][ev[:name]] = { friendly_name: ev[:name], interesting: true, photos: [photo.md5] }
      end

      result
    else
      {}
    end
  end
end
