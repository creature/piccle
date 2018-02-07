require "pry-byebug"
require "piccle/database"
require "piccle/photo"
require "piccle/streams"
require "piccle/streams/date_stream"
require "piccle/template_helpers"
require "piccle/version"

module Piccle
  FULL_SIZE = 1737 # Longest edge
  THUMBNAIL_SIZE = 300 # Thumbnail, square
  AUTHOR_NAME = "Alex Pounds" # TODO: extract this out to a config file.
end
