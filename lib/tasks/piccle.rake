require 'json'
require 'flavour_saver'
require 'slim'
require 'piccle'
require 'rmagick'

namespace :piccle do
  desc "Generate our website"
  task :generate do
    puts "Generating website..."
    puts "    ... (one day) ensuring that database is up to date..."
    generate_json
    generate_html
    generate_thumbnails
    puts "    ... (one day) copying static assets..."
    puts "Done."
  end
end

# Stubby, hacky, prototype method that demos generating JSON files.
def generate_json
  puts "    ... generating JSON files..."
  Dir.mkdir("generated") unless Dir.exist?("generated")
  Dir.mkdir("generated/json") unless Dir.exist?("generated/json")

  # Read data from the database
  query = "SELECT file_name, path, width, height, taken_at, camera_name FROM photos;"
  result = database.execute(query)

  # Write it out as JSON
  File.write("generated/json/all.json", result.to_json)
end


# Stubby, hacky, prototype method that demos generating an HTML file.
def generate_html
  puts "    ... generating HTML files..."
  Dir.mkdir("generated") unless Dir.exist?("generated")
  File.write("generated/index.html", Piccle::TemplateHelpers.render("index", photos: photo_data))
end


# Stubby, hacky method that demos generating thumbnails.
def generate_thumbnails
  puts "    ... generating thumbnails..."
  Dir.mkdir("generated") unless Dir.exist?("generated")
  Dir.mkdir("generated/images") unless Dir.exist?("generated/images")
  Dir.mkdir("generated/images/thumbnails") unless Dir.exist?("generated/images/thumbnails")
  Dir.mkdir("generated/images/photos") unless Dir.exist?("generated/images/photos")

  query = "SELECT (path || '/' || file_name) AS file_name FROM photos;"
  database.execute(query).each do |photo|
    puts "        ... thumbnailing #{photo["file_name"]}..."
    img = Magick::Image.read(photo["file_name"]).first
    img.resize_to_fill!(Piccle::THUMBNAIL_SIZE)
    img.write("generated/images/thumbnails/#{File.basename(photo["file_name"])}")
  end
  # Generate a full-size version of this image
  # Generate a (square) thumbnail
end

def photo_data
  query = "SELECT file_name AS thumbnail_src FROM photos ORDER BY taken_at DESC;"
  result = database.execute(query)
  result.map { |r| r.delete_if { |k, _| k.is_a? Fixnum } }
end

def database
  @db ||= SQLite3::Database.new(Piccle::PHOTO_DATABASE_FILENAME)
  @db.results_as_hash = true
  @db
end
