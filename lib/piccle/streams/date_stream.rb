require 'json'

# Enables browsing photos by date.

class Piccle::Streams::DateStream
  def namespace
    "by-date"
  end

  # Standard method called by the parser object. This should return a hash that contains sub-categories (optionally) and a list of :photos for each tier.
  def data_for(photo)
    year, month, day = photo.taken_at.year, photo.taken_at.month, photo.taken_at.day
    { namespace => {
      :friendly_name => "By date",
      year.to_s => {
        month.to_s => {
          day.to_s => { photos: [photo.md5] },
          photos: [photo.md5]
        },
        photos: [photo.md5]
      }
    }
    }
  end

  def generate_json(root_path)
    years.each do |year|
      photos = photos_for(year)

      result = {
        metadata: {
          total: photos.count
        },
        links: {
          html: Piccle::TemplatePaths.browse_by_date_path(year)
        },
        photos: photos.map(&:to_json)
      }
      File.write(json_path_for(root_path, year), result.to_json)
    end
  end

  def generate_html(root_path)
    years.each do |year|
      File.write("#{root_path}/#{Piccle::TemplatePaths.browse_by_date_path(year)}", html_for_year(year))
    end
  end

  def html_for_year(year)
    photos = photos_for(year.to_i).all
    site_metadata = Piccle::TemplateHelpers.site_metadata
    Piccle::TemplateHelpers.render("index", photos: photos, site_metadata: site_metadata, stream: self, relative_path: "../")
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
