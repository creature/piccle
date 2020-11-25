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
    attr_accessor :home_url

    def initialize(options = {})
      @commandline_options = options
      @working_directory = options["working_directory"]
      @home_directory = options["home_directory"]
      @images_directory = options["image-dir"]
      @output_directory = options["output-dir"]
      @events_file = options["events"]
      @debug = options["debug"] || false
      @author = options["author-name"]
      @home_url = options["url"] || "https://example.com/"
      @config_file, @config_source = config_from_file(options["config"], @working_directory, @home_directory)
    end

    # Load the config from a YAML file, if there is one.
    def config_from_file(config, working_directory, home_directory)
      if config && File.exist?(config)
        [YAML.load_file(config), "configuration file #{config} from commandline switch"]
      elsif working_directory && File.exist?(filename = File.join(working_directory, "piccle.config.yaml"))
        [YAML.load_file(filename), "configuration file #{filename} from working directory"]
      elsif home_directory && File.exist?(filename = File.join(home_directory, ".piccle.config.yaml"))
        [YAML.load_file(filename), "configuration file #{filename} from home directory"]
      end
    end

    # Given the name of a config parameter, where was it configured?
    def source_for(option)
      if @commandline_options.key?(option)
        "command line switch"
      elsif @config_file && @config_file.key?(option)
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
      @debug
    end

    # Generate an Atom feed if we're in debug mode and have a home URL, or if we've set it to something other than
    # example.com.
    def atom?
      (@debug && home_url.strip != "") || (home_url.strip != "" && home_url != "https://example.com/")
    end

    # Should we generate Open Graph tags? These do nice unfurls on Twitter, Facebook, Slack etc. when a link is posted.
    # It's the same rule as whether we should generate an Atom feed.
    def open_graph?
      atom?
    end

    # TODO: I don't think these will work with the config file.
    def output_dir
      if @output_directory
        if Pathname.new(@output_directory).relative?
          File.join(@working_directory, @output_directory)
        else
          @output_directory
        end
      else
        File.join(@working_directory, "generated")
      end
    end

    def images_dir
      if @images_directory
        if Pathname.new(@images_directory).relative?
          File.join(@working_directory, @images_directory)
        else
          @images_directory
        end
      else
        File.join(@working_directory, "images")
      end
    end

    # Who should be credited as the author of these photos?
    def author_name
      get_option("author-name", "An Anonymous Photographer")
    end

    def events_file
      get_option("events", File.join(@working_directory, "events.yaml"))
    end

    protected

    # If cli_var is set, use it. Otherwise, look for the option in the config file. Otherwise, use the default.
    def get_option(config_key, default)
      if @commandline_options.key?(config_key)
        @commandline_options[config_key]
      elsif @config_file && @config_file.key?(config_key)
        @config_file[config_key]
      else
        default
      end
    end
  end
end
