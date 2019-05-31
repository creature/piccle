require "pry-byebug"
require "piccle/database"
require "piccle/keyword"
require "piccle/parser"
require "piccle/photo"
require "piccle/renderer"
require "piccle/streams"
require "piccle/streams/camera_stream"
require "piccle/streams/date_stream"
require "piccle/streams/keyword_stream"
require "piccle/template_helpers"
require "piccle/template_paths"
require "piccle/version"

module Piccle
  FULL_SIZE = 1737 # Longest edge
  THUMBNAIL_SIZE = 300 # Thumbnail, square
  AUTHOR_NAME = "Alex Pounds" # TODO: extract this out to a config file.
end
