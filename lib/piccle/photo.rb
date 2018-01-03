require 'exifr/jpeg'
require 'digest'
require 'sequel'
require 'rmagick'

DB = Piccle::Database.connect

# Represents an image in the system. Reading info from an image? Inferring something based on the data? Put it here.
class Piccle::Photo < Sequel::Model

  # For now, our image will always be initialised from a file_name.
  def initialize(file_name)
    @full_path = file_name
    @exif_info = EXIFR::JPEG.new(@full_path)
  end

  # ---- EXIF accessors ----

  # How wide is this image, in pixels?
  def width
    @exif_info.width
  end

  # How tall is this image, in pixels?
  def height
    @exif_info.height
  end

  # What camera model took this image?
  def model
    @exif_info.model
  end

  # When was this image taken?
  def taken_at
    @exif_info.date_time.to_datetime.to_s
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
    @md5 ||= Digest::MD5.file(@full_path).to_s
  end

  def path
    File.dirname(@full_path)
  end

  def file_name
    File.basename(@full_path)
  end

  # Gets the full path to the thumbnail for this photo.
  def thumbnail_path
    "generated/images/thumbnails/#{md5}.#{file_name}"
  end

  # ---- Piccle internals ----

  # Generate a thumbnail for this image.
  def generate_thumbnail!
    img = Magick::Image.read(@full_path).first
    img.resize_to_fill!(Piccle::THUMBNAIL_SIZE)
    img.write(thumbnail_path)
  end

  # Persist info about this file to the DB.
  def save
    existence_query = "SELECT 1 FROM photos WHERE file_name = ?"
    creation_query = "INSERT INTO photos (file_name, path, md5, width, height, camera_name, taken_at, created_at) VALUES (?, ?, ?, ?, ?, ?, ?, DATETIME());"
    update_query = "UPDATE photos SET md5 = ?, width = ?, height = ?, camera_name = ?, taken_at = ? WHERE file_name = ?;"

    db = SQLite3::Database.new(Piccle::PHOTO_DATABASE_FILENAME)
    result = db.execute(existence_query, [file_name])
    if result.empty?
      db.execute(creation_query, [file_name, path, md5, width, height, model, taken_at])
    else
      db.execute(update_query, [md5, width, height, model, taken_at, file_name])
    end
  end
end
