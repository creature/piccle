require 'exifr/jpeg'
require 'digest'

# Represents an image in the system. Reading info from an image? Inferring something based on the data? Put it here.
class Piccle::Photo

  def initialize(filename)
    @filename = filename
    @exif_info = EXIFR::JPEG.new(filename)
  end

  # How wide is this image, in pixels?
  def width
    @exif_info.width
  end

  # How tall is this image, in pixels?
  def height
    @exif_info.height
  end

  # Is this image portrait?
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
    Digest::MD5.file(@filename)
  end
end
