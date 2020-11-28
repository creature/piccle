require "simplecov"
require "simplecov-console"

Dir["./spec/support/**/*.rb"].each { |f| require f }

unless ENV["SKIP_COVERAGE"]
  SimpleCov.start do
    SimpleCov.formatter = SimpleCov::Formatter::Console
  end
end

$LOAD_PATH.unshift File.expand_path("../../lib", __FILE__)
require "piccle"
Piccle.config = Piccle::Config.new("database" => "piccle_test.db", "working_directory" => Bundler.root.join("spec"),
                                  "home_directory" => Bundler.root.join("spec"))

RSpec.configure do |config|
  config.around(:each) do |example|
    Piccle.config.db.transaction(rollback: :always, auto_savepoint: true) { example.run }
  end

  config.after(:suite) do
    if Pathname.new(Piccle.config.database_file).absolute? && Piccle.config.database_file.start_with?(Bundler.root.to_s)
      File.delete(Piccle.config.database_file)
    end
  end
end
