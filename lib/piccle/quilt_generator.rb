require 'rmagick'

# Generates an image quilt, ideal for OpenGraph previews.
module Piccle
  class QuiltGenerator
    # Generates a quilt of the given images - up to 9.
    def self.generate_for(photo_paths)
      photo_paths = photo_paths.first(9)
      image_list = Magick::ImageList.new(*photo_paths)
      image_list.montage do |conf|
        conf.border_width = 0
        conf.geometry = "200x200+0+0"
      end
    end

    # Returns a tuple of [width, height] output dimensions. When we stitch a quilt together each square is 200px,
    # but variable numbers of images can lead to quilts of different sizes. OpenGraph tags should include this
    # size information.
    def self.dimensions_for(image_count)
      case image_count
      when 1 then [200, 200]
      when 2 then [400, 200]
      when 3 then [600, 200]
      when 4 then [400, 400]
      when 5..6 then [600, 400]
      else [600, 600]
      end
    end
  end
end
