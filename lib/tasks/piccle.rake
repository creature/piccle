require 'json'
require 'fileutils'
require 'handlebars'
require 'slim'
require 'piccle'

namespace :piccle do
  desc "Generate our website"
  task generate: "photos:update_db" do
    puts "Generating website..."
    generate_json
    generate_html
    generate_thumbnails
    copy_assets
    puts "Done."
  end

  desc "Run a web server FOR PREVIEWING OUR OUTPUT ONLY"
  task server: "photos:update_db" do
    puts "Running server..."
    sh %{ ruby lib/piccle/web_server.rb }
  end

  desc "A newer, better generator"
  task new_generate: "photos:update_db" do
    puts "Generating website..."

    parser = new_parser_with_streams
    parse_photos(parser)
    puts parser.inspect
    generate_html_indexes(parser)
    generate_html_photos(parser)
  end
end

# Get a parser, with a couple of registered streams as a demo.
def new_parser_with_streams
  Piccle::Parser.new.tap do |p|
    p.add_stream(Piccle::Streams::DateStream)
    p.add_stream(Piccle::Streams::CameraStream)
  end
end

# Load all the photos, and parse them all.
def parse_photos(parser)
  Piccle::Photo.all.each do |p|
    parser.parse(p)
  end

end

# Given a parser object, generate some HTML index pages from the data it contains.
def generate_html_indexes(parser)
  renderer = Piccle::Renderer.new(parser)
  File.write("generated/index.html", renderer.render_main_index)
end

# Given a parser object, generate photo pages from the data it contains.
def generate_html_photos(parser)

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

  streams.each do |s|
    s.generate_json("generated/json")
  end
end


# Stubby, hacky, prototype method that demos generating an HTML file.
def generate_html
  puts "    ... generating HTML files..."
  FileUtils.mkdir_p("generated/photos") # For individual photo HTML pages, not the images themselves
  photos = Piccle::Photo.reverse_order(:taken_at).all
  site_metadata = Piccle::TemplateHelpers.site_metadata

  # Generate the home page
  File.write("generated/index.html", Piccle::TemplateHelpers.render("index", photos: photos, site_metadata: site_metadata, relative_path: "./"))

  # Generate a page for every single image.
  photos.each do |p|
    File.write("generated/#{p.photo_show_path}", Piccle::TemplateHelpers.render("show", photo: p, site_metadata: site_metadata, relative_path: "../"))
  end

  # Generate pages for each feature stream.
  streams.each do |s|
    s.generate_html("generated")
  end
end


# Stubby, hacky method that demos generating thumbnails.
def generate_thumbnails
  puts "    ... generating thumbnails..."
  FileUtils.mkdir_p("generated/images/thumbnails")
  FileUtils.mkdir_p("generated/images/photos")

  Piccle::Photo.all.each do |photo|
    print "        ... generating #{photo.thumbnail_path}... "
    if photo.thumbnail_exists?
      puts "Already exists, skipping."
    else
      photo.generate_thumbnail!
      puts "Done."
    end

    print "        ... generating #{photo.full_image_path}... "
    if photo.full_image_exists?
      puts "Already exists, skipping."
    else
      photo.generate_full_image!
      puts "Done."
    end
  end
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

def database
  @db ||= SQLite3::Database.new(Piccle::Database::PHOTO_DATABASE_FILENAME)
  @db.results_as_hash = true
  @db
end

def streams
  [Piccle::Streams::DateStream.new, Piccle::Streams::CameraStream.new]
end
