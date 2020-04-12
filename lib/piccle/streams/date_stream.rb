require 'json'

# Enables browsing photos by date.

class Piccle::Streams::DateStream
  def namespace
    "by-date"
  end

  # Standard method called by the parser object. This should return a hash that contains sub-categories (optionally) and a list of :photos for each tier.
  def data_for(photo)
    year, month, day = photo.taken_at&.year, photo.taken_at&.month, photo.taken_at&.day
    if year && month && day
      { namespace => {
        :friendly_name => "By Date",
        year.to_s => {
          month.to_s => {
            day.to_s => { photos: [photo.md5] },
            photos: [photo.md5]
          },
          photos: [photo.md5]
        }
      }}
    else
      {}
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
