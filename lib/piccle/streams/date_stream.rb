require 'json'

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

      result = {
        metadata: {
          total: photos.count
        },
        links: {
          html: html_path_for(year)
        },
        photos: photos.map(&:to_json)
      }
      File.write(json_path_for(root_path, year), result.to_json)
    end
  end

  def generate_html(root_path)
    years.each do |year|
      photos = photos_for(year).all
      site_metadata = Piccle::TemplateHelpers.site_metadata
      File.write("#{root_path}/#{html_path_for(year)}", Piccle::TemplateHelpers.render("index", photos: photos, site_metadata: site_metadata, relative_path: "../"))
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
  def json_path_for(root, year)
    File.join(root, namespace, "#{year}.json")
  end

  # Which years do we have photos for?
  def years
    @years ||= Piccle::Photo.db['SELECT DISTINCT STRFTIME("%Y", taken_at) AS year FROM photos ORDER BY year DESC'].all.map(&:values).flatten.map(&:to_i)
  end
end
