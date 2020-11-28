require 'yaml'

# A special-case stream that handles named "events". You can define details in events.yaml - with things like a name,
# dates, and whether it should be collapsed or not on the front page.

class Piccle::Streams::EventStream < Piccle::Streams::BaseStream
  attr_accessor :events

  def namespace
    "by-event"
  end

  def initialize
    @events = if File.exist?(Piccle.config.events_file)
                YAML.load_file(Piccle.config.events_file).map do |event| # Convert keys to symbols; bring dates to life.
                  event = event.map { |k, v| [k.to_sym, v] }.to_h
                  event[:from] = event[:from].to_datetime
                  event[:to] = event[:to].to_datetime
                  event
                end
              else
                []
              end
  end

  def data_for(photo)
    if photo.taken_at
      relevant_events = @events.select { |ev| photo.taken_at.to_datetime >= ev[:from] && photo.taken_at.to_datetime <= ev[:to] }
      result = { namespace => { friendly_name: "By Event", interesting: true }}
      relevant_events.each do |ev|
        result[namespace][slugify(ev[:name])] = { friendly_name: ev[:name], interesting: true, photos: [photo.md5] }
      end

      result
    else
      {}
    end
  end

  # Sorts most recent events first; then organises photos by date. TODO
  def order(data)
    super(data)
  end

  # Given an event name, get a selector hash for this event.
  def selector_for(name)
    [namespace, slugify(name)]
  end

  # "Sentinels" are data hashes that mark the start and end of an event. We use them to render tiles in the overall
  # index page, if we have photos for the declared event. Each event has an event_start and an event_end marker.
  #
  # Returns an array of 2 items: [event_starts, event_ends]
  def sentinels_for(data)
    event_starts = {}
    event_ends = {}
    @events.each do |event|
      slug = slugify(event[:name])
      if data.dig(namespace, slug, :photos)&.any?
        most_recent_hash = data[namespace][slug][:photos].first
        oldest_hash = data[namespace][slug][:photos].last # Event starts are the furthest back in time!
        event_starts[oldest_hash] = { name: event[:name], selector: selector_for(event[:name]) }
        event_ends[most_recent_hash] = { name: event[:name], selector: selector_for(event[:name]) }
      end
    end

    [event_starts, event_ends]
  end
end
