require 'exifr/jpeg'
require 'xmp'
require 'digest'
require 'sequel'
require 'rmagick'
require 'json'

DB = Piccle::Database.connect

# Represents an image in the system. Reading info from an image? Inferring something based on the data? Put it here.
class Piccle::Photo < Sequel::Model
  many_to_many :keywords
  attr_accessor :modified # Has this file been modified?
  attr_accessor :freshly_created # Have we just generated this file?

  def before_create
    self.created_at ||= Time.now
    super
  end

  def self.from_file(path_to_file)
    freshly_created = false
    md5 = Digest::MD5.file(path_to_file).to_s

    photo = self.find_or_create(file_name: File.basename(path_to_file), path: File.dirname(path_to_file)) do |p|
      # Block executes when creating a new record.
      freshly_created = true
      p.set(data_hash(path_to_file))
    end
    photo.modified = md5 != photo.md5
    photo.freshly_created = freshly_created

    # Pull out keywords for this file, if it's new or changed.
    photo.generate_keywords if freshly_created || photo.modified?

    photo
  end

  # Gets a dataset of properties to save to the file. We reuse this between from_file (above) and update_from_file
  # (below).
  def self.data_hash(path_to_file)
    exif_info = EXIFR::JPEG.new(path_to_file)
    xmp = XMP.parse(exif_info)
    p = {}

    p[:md5] = Digest::MD5.file(path_to_file).to_s
    p[:width] = exif_info.width
    p[:height] = exif_info.height
    p[:camera_name] = exif_info.model || "Unknown"
    p[:description] = exif_info.image_description
    p[:aperture] = exif_info.aperture_value
    p[:iso] = exif_info.iso_speed_ratings
    p[:iso] = p[:iso].first if p[:iso].is_a? Array
    p[:shutter_speed_numerator] = exif_info.exposure_time&.numerator
    p[:shutter_speed_denominator] = exif_info.exposure_time&.denominator
    p[:focal_length] = exif_info.focal_length.to_f
    p[:taken_at] = exif_info.date_time_original&.to_datetime

    p[:latitude] = if exif_info.gps_latitude && exif_info.gps_latitude_ref
                      exif_info.gps_latitude_ref == "S" ? (exif_info.gps_latitude.to_f * -1) : exif_info.gps_latitude.to_f
                    end

    p[:longitude] = if exif_info.gps_longitude && exif_info.gps_longitude_ref
                      exif_info.gps_longitude_ref == "W" ? (exif_info.gps_longitude.to_f * -1) : exif_info.gps_longitude.to_f
                    end

    p[:title] = if xmp && xmp.namespaces && xmp.namespaces.include?("dc") && xmp.dc.attributes.include?("title")
                  xmp.dc.title
                end
    p
  end

  # The year our earliest photo was taken. Used by our copyright footer.
  def self.earliest_photo_year
    Date.parse(self.min(:taken_at)).year
  end

  # The year the last photo was taken. Used by the copyright footer.
  def self.latest_photo_year
    Date.parse(self.max(:taken_at)).year
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

  # Gets the full path to the thumbnail for this photo.
  def thumbnail_path
    "generated#{template_thumbnail_path}"
  end

  # Gets the path to use in our generated HTML.
  def template_thumbnail_path
    Piccle::TemplatePaths.thumbnail_path(self)
  end

  # Does a "full-size" image exist?
  def full_image_exists?
    File.exist?(full_image_path)
  end

  # Gets the full path to the "full" image for this photo.
  def full_image_path
    "generated/#{template_full_image_path}"
  end

  # Gets the path to use in our generated HTML."
  def template_full_image_path
    "images/photos/#{md5}.#{file_name}"
  end

  # Gets the path to the photo page.
  def photo_show_path
    "#{md5}.html"
  end

  def original_photo_path
    "#{path}/#{file_name}"
  end

  # Munge the shutter speed data into a human-readable string.
  def friendly_shutter_speed
    "#{shutter_speed_numerator}/#{shutter_speed_denominator}s"
  end

  # Does this image have both a lat-long pair, AND at least one of (city, state, country)?
  def geocoded?
    (latitude && longitude) && (city || state || country)
  end

  # ---- Piccle internals ----

  # Has this file been modified? You probably want to call update if so.
  def modified?
    modified
  end

  # Have we just created this file?
  def freshly_created?
    freshly_created
  end

  # Re-read the photo data, and save it to the DB.
  def update_from_file
    update(Piccle::Photo.data_hash(original_photo_path))
  end

  # Read the keywords from the photo file, and ensure they're included in the DB.
  # TODO: remove any keywords that aren't currently in the file.
  def generate_keywords
    exif_info = EXIFR::JPEG.new(original_photo_path)
    xmp = XMP.parse(exif_info)

    if xmp && xmp.namespaces && xmp.namespaces.include?("dc") && xmp.dc.attributes.include?("subject")
      xmp.dc.subject.each do |keyword|
        keyword = Piccle::Keyword.find_or_create(name: keyword)
        add_keyword(keyword) unless keywords.include?(keyword)
      end
    end
  end

  # Generate a thumbnail for this image.
  def generate_thumbnail!
    img = Magick::Image.read(original_photo_path).first
    img.resize_to_fill!(Piccle::THUMBNAIL_SIZE)
    img.write(thumbnail_path)
  end

  def generate_full_image!
    img = Magick::Image.read(original_photo_path).first
    img.resize_to_fit!(Piccle::FULL_SIZE, Piccle::FULL_SIZE)
    img.write(full_image_path)
  end
end
