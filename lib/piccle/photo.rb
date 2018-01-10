require 'exifr/jpeg'
require 'digest'
require 'sequel'
require 'rmagick'

DB = Piccle::Database.connect

# Represents an image in the system. Reading info from an image? Inferring something based on the data? Put it here.
class Piccle::Photo < Sequel::Model
  def before_create
    self.created_at ||= Time.now
    super
  end

  def self.from_file(path_to_file)
    self.find_or_create(file_name: File.basename(path_to_file), path: File.dirname(path_to_file)) do |p|
      p[:width] = p.width
      p[:height] = p.height
      p[:camera_name] = p.camera_model
      p[:md5] = p.md5
      p[:taken_at] = p.taken_at
    end
  end

  # ---- EXIF accessors ----

  # How wide is this image, in pixels?
  def width
    exif_info.width
  end

  # How tall is this image, in pixels?
  def height
    exif_info.height
  end

  # What camera model took this image?
  def camera_model
    exif_info.model
  end

  # When was this image taken?
  def taken_at
    exif_info.date_time_original.to_datetime.to_s
  end

  # ---- Image attributes (inferred from data) ----

  def portrait?
    height > width
  end

  # Is this image landscape?
  def landscape?
    width > height
  end

  # Is this image square?
  def square?
    width == height
  end

  # Have we already generated a thumbnail for this image?
  def thumbnail_exists?
    File.exist?(thumbnail_path)
  end

  # Gets an MD5 hash of this file's entire contents.
  def md5
    @md5 ||= Digest::MD5.file(original_photo_path).to_s
  end

  # Gets the full path to the thumbnail for this photo.
  def thumbnail_path
    "generated/#{template_thumbnail_path}"
  end

  # Gets the path to use in our generated HTML.
  def template_thumbnail_path
    "images/thumbnails/#{md5}.#{file_name}"
  end

  def original_photo_path
    "#{path}/#{file_name}"
  end

  # ---- Piccle internals ----

  # Generate a thumbnail for this image.
  def generate_thumbnail!
    img = Magick::Image.read(original_photo_path).first
    img.resize_to_fill!(Piccle::THUMBNAIL_SIZE)
    img.write(thumbnail_path)
  end

  protected

  def exif_info
    @exif_info ||= EXIFR::JPEG.new(original_photo_path)
  end
end
