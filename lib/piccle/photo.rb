require 'exifr/jpeg'
require 'xmp'
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
      common_attrs = %i(width height md5 taken_at description title aperture iso)
      common_attrs.each { |att| p[att] = p.send(att) }
      p[:camera_name] = p.camera_model
      shutter_speed = p.shutter_speed
      p[:shutter_speed_numerator] = shutter_speed.numerator
      p[:shutter_speed_denominator] = shutter_speed.denominator
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

  # What's the title for this image?
  def title
    if xmp.namespaces.include?("dc") && xmp.dc.attributes.include?("title")
      xmp.dc.title
    else
      nil
    end
  end

  # What's the description (ie. the caption) for this image?
  def description
    exif_info.image_description
  end

  # What's the aperture for this image? You get this as a decimal, and should be expressed as f/{aperture}.
  def aperture
    exif_info.aperture_value
  end

  def iso
    exif_info.iso_speed_ratings
  end

  def shutter_speed
    exif_info.exposure_time
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

  # Gets an MD5 hash of this file's entire contents.
  def md5
    @md5 ||= Digest::MD5.file(original_photo_path).to_s
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
    "images/thumbnails/#{md5}.#{file_name}"
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
    "photos/#{md5}.html"
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

  def generate_full_image!
    img = Magick::Image.read(original_photo_path).first
    img.resize_to_fit!(Piccle::FULL_SIZE, Piccle::FULL_SIZE)
    img.write(full_image_path)
  end

  protected

  def exif_info
    @exif_info ||= EXIFR::JPEG.new(original_photo_path)
  end

  def xmp
    @xmp ||= XMP.parse(exif_info)
  end
end
