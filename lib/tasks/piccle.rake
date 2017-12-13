require 'json'
require 'flavour_saver'
require 'slim'
require 'piccle'

namespace :piccle do
  desc "Generate our website"
  task :generate do
    puts "Generating website..."
    puts "    ... (one day) ensuring that database is up to date..."
    puts "    ... (one day) generating JSON files..."
    generate_json
    puts "    ... (one day) generating HTML files..."
    generate_html
    puts "    ... (one day) generating required thumbnails..."
    puts "    ... (one day) copying static assets..."
    puts "Done."
  end
end

def generate_json
  Dir.mkdir("generated") unless Dir.exist?("generated")
  Dir.mkdir("generated/json") unless Dir.exist?("generated/json")

  # Read data from the database
  query = "SELECT file_name, path, width, height, taken_at, camera_name FROM photos;"
  result = database.execute(query)

  # Write it out as JSON
  File.write("generated/json/all.json", result.to_json)
end

def generate_html
  Dir.mkdir("generated") unless Dir.exist?("generated")
  File.write("generated/index.html", Piccle::TemplateHelpers.render("index", photos: photo_data))
end

def photo_data
  query = "SELECT file_name AS thumbnail_src FROM photos ORDER BY taken_at DESC;"
  result = database.execute(query)
  result.map { |r| r.delete_if { |k, _| k.is_a? Fixnum } }
end

def database
  @db ||= SQLite3::Database.new("photo_data.db")
  @db.results_as_hash = true
  @db
end
