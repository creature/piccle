require 'exifr/jpeg'
require 'xmp'
require 'digest'
require 'sequel'
require 'rmagick'
require 'json'

# Represents an image in the system. Reading info from an image? Inferring something based on the data? Put it here.
class Piccle::Photo < Sequel::Model
  many_to_many :keywords
  many_to_many :people
  attr_accessor :changed_hash # Has this file been modified?
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
    photo.changed_hash = md5 != photo.md5
    photo.freshly_created = freshly_created

    # Pull out keywords for this file, if it's new or changed.
    if freshly_created || photo.changed_hash?
      photo.sync_keywords
      photo.sync_people
    end

    photo
  end

  # Gets a dataset of properties to save about this file. We reuse this between from_file (above) and update_from_file
  # (below).
  def self.data_hash(path_to_file)
    exif_info = EXIFR::JPEG.new(path_to_file)
    xmp = XMP.parse(exif_info)
    p = {}

    p[:md5] = Digest::MD5.file(path_to_file).to_s
    p[:width] = exif_info.width
    p[:height] = exif_info.height
    p[:camera_name] = exif_info.model || "Unknown camera"
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
    %w[City State Country].each do |location|
      p[location.downcase.to_sym] = if xmp && xmp.namespaces && xmp.namespaces.include?("photoshop") &&
                                        xmp.photoshop.attributes.include?(location)
                                      xmp.photoshop.send(location)
                                    end
    end

    # Tweak encoding of potential non-UTF-8 strings
    %i[description title city state country].each do |attr|
      p[attr].force_encoding("UTF-8") if p[attr].respond_to?(:force_encoding)
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
    File.join(Piccle.config.output_dir, template_thumbnail_path)
  end

  # Gets the path to use in our generated HTML.
  def template_thumbnail_path
    File.join("images", "thumbnails", "#{md5}.#{file_name}")
  end

  # Does a "full-size" image exist?
  def full_image_exists?
    File.exist?(full_image_path)
  end

  # Gets the full path to the "full" image for this photo.
  def full_image_path
    File.join(Piccle.config.output_dir, template_full_image_path)
  end

  # Gets the path to use in our generated HTML."
  def template_full_image_path
    File.join("images", "photos", "#{md5}.#{file_name}")
  end

  # Gets the path to the photo page.
  def photo_show_path
    "#{md5}.html"
  end

  def original_photo_path
    File.join(path, file_name)
  end

  # Munge the shutter speed data into a human-readable string.
  def friendly_shutter_speed
    if shutter_speed_numerator && shutter_speed_denominator
      if shutter_speed_denominator > 1
        "#{shutter_speed_numerator}/#{shutter_speed_denominator}s"
      else
        "#{shutter_speed_numerator}s"
      end
    end
  end

  def friendly_focal_length
    "#{focal_length.round(1)} mm" if focal_length.positive?
  end

  # Does this image have both a lat-long pair, AND at least one of (city, state, country)?
  def geocoded?
    (latitude && longitude) && (city || state || country)
  end

  # ---- Piccle internals ----

  # Has this file changed hash? You probably want to call update if so.
  def changed_hash?
    changed_hash
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
  def sync_keywords
    exif_info = EXIFR::JPEG.new(original_photo_path)
    xmp = XMP.parse(exif_info)

    if xmp && xmp.namespaces && xmp.namespaces.include?("dc") && xmp.dc.attributes.include?("subject")
      # Add new keywords
      downcased_keywords = xmp.dc.subject.map(&:downcase)
      downcased_keywords.each do |keyword|
        keyword = Piccle::Keyword.find_or_create(name: keyword)
        add_keyword(keyword) unless keywords.include?(keyword)
      end

      # Remove old keywords
      keywords.each { |keyword| remove_keyword(keyword) unless downcased_keywords.include?(keyword.name.downcase) }
    end
  end

  def sync_people
    exif_info = EXIFR::JPEG.new(original_photo_path)
    xmp = XMP.parse(exif_info)

    if xmp && xmp.namespaces && xmp.namespaces.include?("Iptc4xmpExt") && xmp.Iptc4xmpExt.attributes.include?("PersonInImage")
      people_names = xmp.Iptc4xmpExt.PersonInImage
      people_names.each do |name|
        person = Piccle::Person.find(Sequel.ilike(:name, name)) || Piccle::Person.create(name: name)
        add_person(person) unless people.include?(person)
      end

      downcased_names = people_names.map(&:downcase)
      people.each { |person| remove_person(person) unless downcased_names.include?(person.name.downcase) }
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
