# frozen_string_literal: true

# Considers commandline arguments, config file settings, and defaults. Combines them all to return the correct value
# for config.
#
# Some settings include:
# - Author: who should be credited as the author of these photos?
# - URL: where will this gallery be deployed? The generator generally doesn't care, but we need a full URL to generate
#   Atom feeds and OpenGraph tags.
module Piccle
  class Config
    def initialize(options = {})
      @commandline_options = options
      @working_directory = options["working_directory"] || Dir.pwd
      @home_directory = options["home_directory"] || Dir.home
      @images_directory = options["image-dir"]
      @output_directory = options["output-dir"]
      @config_file, @config_source = config_location(options["config"], @working_directory, @home_directory)
      @config_file_options = @config_file ? YAML.load_file(@config_file) : {}
      @db = nil # The Sequel database itself.
    end

    # Return the path the config file, as well as where we found it.
    def config_location(config, working_directory, home_directory)
      if config && File.exist?(config)
        [config, "configuration file #{config} from commandline switch"]
      elsif working_directory && File.exist?(filename = File.join(working_directory, "piccle.config.yaml"))
        [filename, "configuration file #{filename} from working directory"]
      elsif home_directory && File.exist?(filename = File.join(home_directory, ".piccle.config.yaml"))
        [filename, "configuration file #{filename} from home directory"]
      end
    end

    # Given the name of a config parameter, where was it configured?
    def source_for(option)
      if @commandline_options.key?(option)
        "command line switch"
      elsif @config_file_options.key?(option)
        @config_source
      else
        "piccle default"
      end
    end

    def using_default?(option)
      source_for(option) == "piccle default" # TODO: use a proper boolean check here.
    end

    # Debug mode outputs some extra info, and makes some safety-checks less strict.
    def debug?
      get_option("debug", false)
    end

    def ruby_renderer?
      get_option("ruby-renderer", false)
    end

    # Generate an Atom feed if we're in debug mode and have a home URL, or if we've set it to something other than
    # example.com.
    def atom?
      (debug? && home_url.strip != "") || (home_url.strip != "" && home_url != "https://example.com/")
    end

    # Should we generate Open Graph tags? These do nice unfurls on Twitter, Facebook, Slack etc. when a link is posted.
    # It's the same rule as whether we should generate an Atom feed.
    def open_graph?
      atom?
    end

    def output_dir
      get_filename_option("output-dir", File.join(@working_directory, "generated"))
    end

    def images_dir
      get_filename_option("image-dir", File.join(@working_directory, "images"))
    end

    # Who should be credited as the author of these photos?
    def author_name
      get_option("author-name", "An Anonymous Photographer")
    end

    def home_url
      get_option("url", "https://example.com/")
    end

    def events_file
      get_option("events", File.join(@working_directory, "events.yaml"))
    end

    # Gets the path to the database file.
    def database_file
      get_filename_option("database", File.join(@working_directory, "piccle.db"))
    end

    # Does the DB file exist?
    def database_exists?
      File.exist?(database_file)
    end

    # Gets the Sequel database itself.
    def db
      @db ||= Piccle::Database.new(database_file)
    end

    protected

    # If cli_var is set, use it. Otherwise, look for the option in the config file. Otherwise, use the default.
    def get_option(config_key, default)
      if @commandline_options.key?(config_key)
        @commandline_options[config_key]
      elsif @config_file_options.key?(config_key)
        @config_file_options[config_key]
      else
        default
      end
    end

    # Similar to the above - return CLI option if given, otherwise check the config file, otherwise return the default.
    # The difference is this is for filenames/directories - it also resolves absolute vs. relative paths.
    def get_filename_option(config_key, default)
      if filename = @commandline_options[config_key]
        Pathname.new(filename).relative? ? File.join(@working_directory, filename) : filename
      elsif filename = @config_file_options[config_key]
        Pathname.new(filename).relative? ? File.absolute_path(File.join(File.dirname(@config_file), filename)) : filename
      else
        default
      end
    end
  end
end
