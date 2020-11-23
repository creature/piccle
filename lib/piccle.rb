require "piccle/config"
require "piccle/database"
require "piccle/extractor"
require "piccle/parser"
require "piccle/renderer"
require "piccle/streams"
require "piccle/streams/base_stream"
require "piccle/streams/camera_stream"
require "piccle/streams/date_stream"
require "piccle/streams/event_stream"
require "piccle/streams/keyword_stream"
require "piccle/streams/location_stream"
require "piccle/template_helpers"
require "piccle/version"

module Piccle
  FULL_SIZE = 1737 # Longest edge
  THUMBNAIL_SIZE = 300 # Thumbnail, square
  DEBUG = true # Output some debug info on web pages when true.
  EVENT_YAML_FILE = "events.yaml" # A file with a list of "events", named things that we want to generate pages for.

  DB = Piccle::Database.connect
  Sequel::Model.db = DB
  Dir["lib/piccle/models/*.rb"].each { |f| require f.delete_prefix("lib/").delete_suffix(".rb") }
  models = [Piccle::Photo, Piccle::Keyword, Piccle::Location]
  models.each(&:finalize_associations)
  models.each(&:freeze)
  DB.freeze

  @@config = Piccle::Config.new

  def config
    @@config
  end

  def config=(new_config)
    @@config = new_config
  end

  module_function :config, :config=
end
