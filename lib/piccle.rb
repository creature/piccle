require "pry-byebug"
require "piccle/photo"
require "piccle/template_helpers"
require "piccle/version"

module Piccle
  PHOTO_DATABASE_FILENAME = "photo_data.db"
  FULL_SIZE = 1158 # Shortest edge
  THUMBNAIL_SIZE = 300 # Thumbnail, square
end
