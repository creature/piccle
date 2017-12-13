# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'piccle/version'

Gem::Specification.new do |spec|
  spec.name          = "piccle"
  spec.version       = Piccle::VERSION
  spec.authors       = ["Alex Pounds"]
  spec.email         = ["alex+git@alexpounds.com"]

  spec.summary       = %q{A static site generator for photographers}
  spec.homepage      = "TODO: Put your gem's website or public repo URL here."

  # Prevent pushing this gem to RubyGems.org. To allow pushes either set the 'allowed_push_host'
  # to allow pushing to a single host or delete this section to allow pushing to any host.
  if spec.respond_to?(:metadata)
    spec.metadata['allowed_push_host'] = "TODO: Set to 'http://mygemserver.com'"
  else
    raise "RubyGems 2.0 or newer is required to protect against " \
      "public gem pushes."
  end

  spec.files         = `git ls-files -z`.split("\x0").reject do |f|
    f.match(%r{^(test|spec|features)/})
  end
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.13"
  spec.add_development_dependency "rspec", "~> 3.0"

  spec.add_dependency "pry-byebug", "~> 3.5" # Debugging aid; only needed by developers.
  spec.add_dependency "rake", "~> 10.0" # Ruby task runner
  spec.add_dependency "flavour_saver", "~> 0.3" # Handlebars templating in Ruby
  spec.add_dependency "slim", "~> 3.0" # Templating language, so we don't have to write longhand HTML
  spec.add_dependency "exifr", "~> 1.3" # EXIF reading library
  spec.add_dependency "sqlite3", "~> 1.3" # Simple file-based database
  spec.add_dependency "recursive-open-struct", "~> 1.0" # Blesses database results into objects compatible with flavour-saver
  spec.add_dependency "rmagick", "~> 2.0" # Image processing library
end
