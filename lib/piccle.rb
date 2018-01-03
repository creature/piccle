require "pry-byebug"
require "piccle/database"
require "piccle/photo"
require "piccle/template_helpers"
require "piccle/version"

module Piccle
  FULL_SIZE = 1158 # Shortest edge
  THUMBNAIL_SIZE = 300 # Thumbnail, square
  AUTHOR_NAME = "Alex Pounds" # TODO: extract this out to a config file.
end
