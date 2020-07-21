require "simplecov"
require "simplecov-console"

ENV['PICCLE_ENV'] = "test".freeze
Dir["./spec/support/**/*.rb"].each { |f| require f }

SimpleCov.start do
  SimpleCov.formatter = SimpleCov::Formatter::Console
end

$LOAD_PATH.unshift File.expand_path("../../lib", __FILE__)
require "piccle"
