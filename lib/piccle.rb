require "piccle/database"
require "piccle/extractor"
require "piccle/keyword"
require "piccle/location"
require "piccle/parser"
require "piccle/photo"
require "piccle/renderer"
require "piccle/streams"
require "piccle/streams/base_stream"
require "piccle/streams/camera_stream"
require "piccle/streams/date_stream"
require "piccle/streams/event_stream"
require "piccle/streams/keyword_stream"
require "piccle/streams/location_stream"
require "piccle/template_helpers"
require "piccle/template_paths"
require "piccle/version"

module Piccle
  FULL_SIZE = 1737 # Longest edge
  THUMBNAIL_SIZE = 300 # Thumbnail, square
  AUTHOR_NAME = "Alex Pounds" # TODO: extract this out to a config file.
  DEBUG = true # Output some debug info on web pages when true.
  EVENT_YAML_FILE = "events.yaml" # A file with a list of "events", named things that we want to generate pages for.
  HOME_URL = "https://example.com/" # OpenGraph and Atom feeds need a fully-qualified URL. This is used to generate them.
end
