class Piccle::TemplatePaths
  def self.index_path
    "/"
  end

  def self.browse_by_date_path(year=nil, month=nil, day=nil)
    if year && month && day
      "/by-date/#{year}/#{month}/#{day}.html"
    elsif year && month
      "/by-date/#{year}/#{month}.html"
    elsif year
      "/by-date/#{year}.html"
    else
      "/by-date"
    end
  end

  def self.browse_by_camera_path
    "/by-camera"
  end

  def self.show_photo_path(photo)
    "/photos/#{photo.md5}.html"
  end

  def self.thumbnail_path(photo)
    "/images/thumbnails/#{photo.md5}.#{photo.file_name}"
  end
end
