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

  def before_create
    self.created_at ||= Time.now
    super
  end

  def self.from_file(path_to_file)
    freshly_created = false
    exif_info = nil
    xmp = nil

    photo = self.find_or_create(file_name: File.basename(path_to_file), path: File.dirname(path_to_file)) do |p|
      # Block executes when creating a new record.
      freshly_created = true
      exif_info = EXIFR::JPEG.new(path_to_file)
      xmp = XMP.parse(exif_info)

      p[:md5] = Digest::MD5.file(path_to_file).to_s
      p[:width] = exif_info.width
      p[:height] = exif_info.height
      p[:camera_name] = exif_info.model
      p[:description] = exif_info.image_description
      p[:aperture] = exif_info.aperture_value
      p[:iso] = exif_info.iso_speed_ratings
      p[:shutter_speed_numerator] = exif_info.exposure_time.numerator
      p[:shutter_speed_denominator] = exif_info.exposure_time.denominator
      p[:focal_length] = exif_info.focal_length.to_f
      p[:taken_at] = exif_info.date_time_original.to_datetime.to_s

      p[:latitude] = if exif_info.gps_latitude && exif_info.gps_latitude_ref
                       exif_info.gps_latitude_ref == "S" ? (exif_info.gps_latitude.to_f * -1) : exif_info.gps_latitude.to_f
                     end

      p[:longitude] = if exif_info.gps_longitude && exif_info.gps_longitude_ref
                        exif_info.gps_longitude_ref == "W" ? (exif_info.gps_longitude.to_f * -1) : exif_info.gps_longitude.to_f
                      end

      p[:title] = if xmp && xmp.namespaces && xmp.namespaces.include?("dc") && xmp.dc.attributes.include?("title")
                    xmp.dc.title
                  end
    end

    # Pull out keywords for this file, if we're creating it for the first time.
    if freshly_created && xmp && xmp.namespaces && xmp.namespaces.include?("dc") && xmp.dc.attributes.include?("subject")
      xmp.dc.subject.each do |keyword|
        keyword = Piccle::Keyword.find_or_create(name: keyword)
        photo.add_keyword(keyword) unless photo.keywords.include?(keyword)
      end
    end
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
    "generated/#{template_thumbnail_path}"
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
    Piccle::TemplatePaths.show_photo_path(self)
  end

  def original_photo_path
    "#{path}/#{file_name}"
  end

  def to_json
    {
      title: title,
      description: description,
      taken_at: taken_at,
    }.to_json
  end

  # ---- Piccle internals ----

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
