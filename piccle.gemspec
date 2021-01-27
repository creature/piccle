# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'piccle/version'

Gem::Specification.new do |spec|
  spec.name = "piccle"
  spec.version = Piccle::VERSION
  spec.authors = ["Alex Pounds"]
  spec.email = ["piccle@alexpounds.com"]
  spec.executables = ["piccle"]

  spec.summary  = "A static site generator for photographers"
  spec.description = "Piccle uses the EXIF data present in your photographs and uses it to build a website that lets
  visitors browse by camera, tag, location, and more."
  spec.homepage = "https://piccle.alexpounds.com/"

  spec.files  = `git ls-files -z`.split("\x0").reject do |f|
    f.match(%r{^(test|spec|features)/})
  end
  spec.bindir = "bin"
  spec.executables = ["piccle"]
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.13"
  spec.add_development_dependency "rspec", "~> 3.0" # Testing library
  spec.add_development_dependency "simplecov" # Code coverage calculator
  spec.add_development_dependency "simplecov-console" # Output stats on the console
  spec.add_development_dependency "pry-byebug", "~> 3.5" # Debugging aid; only needed by developers.
  spec.add_development_dependency "ruby-prof" # Performance profiling.

  spec.add_dependency "exifr", "~> 1.3" # EXIF reading library
  spec.add_dependency "handlebars" # Templating engine, usable both backend and frontend.
  spec.add_dependency "httparty" # Simple HTTP library
  spec.add_dependency "rake" # Ruby task runner
  spec.add_dependency "recursive-open-struct", "~> 1.0" # Blesses database results into objects compatible with flavour-saver
  spec.add_dependency "rmagick", "~> 2.0" # Image processing library
  spec.add_dependency "sequel", "~> 5" # DB access in a structured way
  spec.add_dependency "slim", "~> 3.0" # Templating language, so we don't have to write longhand HTML
  spec.add_dependency "sqlite3", "~> 1.3" # Simple file-based database
  spec.add_dependency "thor" # Nice Ruby CLI builder
  spec.add_dependency "xmp", "~> 0.2" # Read XMP info from files
end
