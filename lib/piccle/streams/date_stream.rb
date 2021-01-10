# frozen_string_literal: true

# Enables browsing photos by date.

class Piccle::Streams::DateStream < Piccle::Streams::BaseStream
  def namespace
    "by-date"
  end

  # Standard method called by the parser object. This should return a hash that contains sub-categories (optionally)
  # and a list of :photos for each tier.
  def data_for(photo)
    year, month, day = photo.taken_at&.year, photo.taken_at&.month, photo.taken_at&.day
    if year && month && day
      { namespace => {
        :friendly_name => "By Date",
        :interesting => false,
        year.to_s => {
          :friendly_name => "#{year}",
          :interesting => false,
          month.to_s => {
            :friendly_name => "#{Date::MONTHNAMES[month]}",
            :interesting => false,
            day.to_s => {
              :friendly_name => "#{day}#{ordinal_for(day)}",
              :interesting => false,
              :photos => [photo.md5]
            },
            :photos => [photo.md5]
          },
          photos: [photo.md5]
        }
      }}
    else
      {}
    end
  end

  def metadata_for(photo)
    year, month, day = photo.taken_at&.year, photo.taken_at&.month, photo.taken_at&.day
    if year && month && day
      [{ friendly_name: "#{day}#{ordinal_for(day)}",
        type: :date_day,
        selector: [namespace, year, month, day]
      }, {
        friendly_name: "#{Date::MONTHNAMES[month]}",
        type: :date_month,
        selector: [namespace, year, month]
      }, {
        friendly_name: year.to_s,
        type: :date_year,
        selector: [namespace, year]
      }]
    else
      []
    end
  end

  # Standard method called by the parser object. Gives this stream an option to re-order its data. The stream is on
  # its honour to only meddle within its own namespace.
  def order(data)
    sort_proc = Proc.new { |k, v| k.is_a?(String) ? k : "" }

    data[namespace] = data[namespace].sort_by(&sort_proc).to_h # Sort years

    data[namespace].each do |year_k, v|
      # Sort photos in each year, and then the month keys
      if year_k.is_a?(String)
        if data[namespace][year_k].key?(:photos)
          data[namespace][year_k][:photos] = data[namespace][year_k][:photos].sort_by(&date_sort_proc(data)).reverse
        end
        data[namespace][year_k] = data[namespace][year_k].sort_by(&sort_proc).to_h

        data[namespace][year_k].each do |month_k, v|
          # Sort photos in each month, and then the days. TODO.
        end
      end
    end
    data
  end

  protected

  def ordinal_for(num)
    if num % 10 == 1 && num != 11
      "st"
    elsif num % 10 == 2 && num != 12
      "nd"
    elsif num % 10 == 3 && num != 13
      "rd"
    else
      "th"
    end
  end
end
