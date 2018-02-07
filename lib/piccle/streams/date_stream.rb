# Enables browsing photos by date.

class Piccle::Streams::DateStream
  def namespace
    "by-date"
  end

  def navigation_items
    years.map { |year| [year, html_path_for(year)] }
  end

  def generate_json(root_path)
    years.each do |year|
      photos = photos_for(year)
      puts "#{photos.count} photos for #{year}"
    end
  end

  def html_path_for(year)
    "#{namespace}/#{year}.html"
  end

  protected

  # Get the photos for a given year
  def photos_for(year)
    start_of_year = Date.new(year)
    end_of_year = Date.new(year + 1)

    Piccle::Photo.where { taken_at >= start_of_year && taken_at < end_of_year }
  end

  #generated/json/by-date/2008.json
  def json_path(root, year)
    File.join(root, namespace, "#{year}.json")
  end

  # Which years do we have photos for?
  def years
    @years ||= Piccle::Photo.db['SELECT DISTINCT STRFTIME("%Y", taken_at) AS year FROM photos ORDER BY year DESC'].all.map(&:values).flatten.map(&:to_i)
  end
end
