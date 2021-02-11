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
                  event[:selector] = selector_for(event[:name])
                  transform_dates(event)
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
        result[namespace][slugify(ev[:name])] = { friendly_name: ev[:name], interesting: true, photos: [photo.md5],
                                                  collapsed: ev[:collapsed], sort_date: ev[:from] }
      end

      result
    else
      {}
    end
  end

  # Sorts most recent events first; then organises photos by date. TODO
  def order(data)
    if data.key?(namespace)
      data[namespace] = data[namespace].sort_by { |k, v| k.is_a?(String) ? v[:sort_date] : DateTime.new(1826, 1, 1) }.reverse.to_h
      data[namespace].each do |k, v|
        data[namespace][k][:photos] = data[namespace][k][:photos].sort_by(&date_sort_proc(data)).reverse if k.is_a?(String)
      end
    end

    data
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
        event_starts[oldest_hash] = { name: event[:name], selector: selector_for(event[:name]), collapsed: event[:collapsed] }
        event_ends[most_recent_hash] = { name: event[:name], selector: selector_for(event[:name]), collapsed: event[:collapsed] }
      end
    end

    [event_starts, event_ends]
  end

  protected

  # Given an event, munge the dates appropriately.
  # - If we have an "at" date specified, make the from/to fields match the start and end of the day.
  # - If we have "from"/"to" specified as dates, line them up with the start/end of the day.
  def transform_dates(event)
    if event[:at]
      event[:from] = DateTime.new(event[:at].year, event[:at].month, event[:at].day, 0, 0, 0)
      event[:to] = DateTime.new(event[:at].year, event[:at].month, event[:at].day, 23, 59, 59)
    elsif event[:from] && event[:to]
      if event[:from].is_a? Date
        event[:from] = DateTime.new(event[:from].year, event[:from].month, event[:from].day, 0, 0, 0)
      end
      if event[:to].is_a? Date
        event[:to] = DateTime.new(event[:to].year, event[:to].month, event[:to].day, 23, 59, 59)
      end
    end
    event
  end
end
