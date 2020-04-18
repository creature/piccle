require 'json'

# Enables browsing photos by date.

class Piccle::Streams::DateStream
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
          :friendly_name => "By Date – #{year}",
          :interesting => false,
          month.to_s => {
            :friendly_name => "By Date - #{Date::MONTHNAMES[month]} #{year}",
            :interesting => false,
            day.to_s => {
              :friendly_name => "By Date – #{day}#{ordinal_for(day)} #{Date::MONTHNAMES[month]} #{year}",
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

  # Standard method called by the parser object. Gives this stream an option to re-order its data. The stream is on
  # its honour to only meddle within its own namespace.
  def order(data)
    sort_proc = Proc.new { |k, v| k.is_a?(String) ? k : "" }
    data[namespace] = data[namespace].sort_by(&sort_proc).to_h # Sort years
    data[namespace].each do |k, v|
      data[namespace][k].sort_by(&sort_proc).to_h if k.is_a?(String) # Sort months
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
