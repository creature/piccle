require 'json'
require 'fileutils'
require 'flavour_saver'
require 'slim'
require 'piccle'

namespace :piccle do
  desc "Generate our website"
  task :generate do
    puts "Generating website..."
    puts "    ... (one day) ensuring that database is up to date..."
    generate_json
    generate_html
    generate_thumbnails
    copy_assets
    puts "Done."
  end
end

# Stubby, hacky, prototype method that demos generating JSON files.
def generate_json
  puts "    ... generating JSON files..."
  FileUtils.mkdir_p("generated/json")

  # Read data from the database
  query = "SELECT file_name, path, width, height, taken_at, camera_name FROM photos;"
  result = database.execute(query)

  # Write it out as JSON
  File.write("generated/json/all.json", result.to_json)
end


# Stubby, hacky, prototype method that demos generating an HTML file.
def generate_html
  puts "    ... generating HTML files..."
  FileUtils.mkdir_p("generated")
  File.write("generated/index.html", Piccle::TemplateHelpers.render("index", photos: photo_data, site_metadata: site_metadata))
end


# Stubby, hacky method that demos generating thumbnails.
def generate_thumbnails
  puts "    ... generating thumbnails..."
  FileUtils.mkdir_p("generated/images/thumbnails")
  FileUtils.mkdir_p("generated/images/photos")

  query = "SELECT (path || '/' || file_name) AS file_name FROM photos;"
  database.execute(query).each do |photo|
    photo = Piccle::Photo.new(photo["file_name"])
    print "        ... generating #{photo.thumbnail_path}... "
    if photo.thumbnail_exists?
      puts "Already exists, skipping."
    else
      photo.generate_thumbnail!
      puts "Done."
    end
  end
  # Generate a full-size version of this image
  # Generate a (square) thumbnail
end

# Copy our static assets into the expected location.
def copy_assets
  puts "    ... copying static assets..."
  puts "        ... copying CSS..."
  FileUtils.mkdir_p("generated/css")
  Dir.glob("assets/css/**").each do |f|
    FileUtils.cp(f, "generated/css/#{File.basename(f)}")
  end
end

def photo_data
  query = "SELECT file_name AS thumbnail_src FROM photos ORDER BY taken_at DESC;"
  result = database.execute(query)
  result.map { |r| r.delete_if { |k, _| k.is_a? Fixnum } }
end

# Gets information about our site.
def site_metadata
  OpenStruct.new(
    author_name: Piccle::AUTHOR_NAME,
    copyright_year: copyright_year
  )
end

# Gets a string describing the copyright year - either with a hyphen for multiple year spans, or one number for one year.
def copyright_year
  result = database.execute("SELECT MIN(STRFTIME('%Y', taken_at)) AS min_year, MAX(STRFTIME('%Y', taken_at)) AS max_year FROM photos;").first
  if result["min_year"] == result["max_year"]
    result["max_year"]
  else
    "#{result["min_year"]} – #{result["max_year"]}"
  end
end

def database
  @db ||= SQLite3::Database.new(Piccle::PHOTO_DATABASE_FILENAME)
  @db.results_as_hash = true
  @db
end
