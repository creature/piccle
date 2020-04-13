class Piccle::TemplatePaths
  def self.thumbnail_path(photo)
    "/images/thumbnails/#{photo.md5}.#{photo.file_name}"
  end
end
