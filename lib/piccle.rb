require "piccle/config"
require "piccle/database"
require "piccle/dstk_service"
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

  @@config = Piccle::Config.new

  def config
    @@config
  end

  def config=(new_config)
    @@config = new_config
  end

  # We defer the loading of our model classes until their first access, so a user can configure their DB location.
  # When bin/piccle is run, we require 'piccle' immediately. But Sequel models must have a DB connection so they can
  # reflect from the schema to define their fields. We can't require 'piccle', load the models, and then swap out the
  # DB for a configured version later.
  # Instead, we use const_missing to load all our models when we first try to access one.
  def Piccle.const_missing(name)
    Sequel::Model.db = Piccle.config.db

    if %i[Photo Keyword Location].include?(name)
      Dir[Bundler.root.join("lib", "piccle", "models", "*.rb")].each { |f| require f.delete_prefix("lib/").delete_suffix(".rb") }
      models = [Piccle::Photo, Piccle::Keyword, Piccle::Location]
      models.each(&:finalize_associations)
      models.each(&:freeze)
    end

    const_get(name)
  end

  module_function :config, :config=
end
