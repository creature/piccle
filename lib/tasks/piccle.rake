require 'json'
require 'fileutils'
require 'handlebars'
require 'slim'
require 'piccle'

namespace :piccle do
  desc "Generate our website"
  task generate: "photos:update_db" do |task, args|
    start_time = Time.now
    puts "Generating website..."

    parser = new_parser_with_streams
    parse_photos(parser)
    renderer = Piccle::Renderer.new(parser)

    generate_rss_feeds(parser, renderer)
    generate_html_indexes(parser, renderer)
    generate_html_photos(parser, renderer)
    generate_json(parser, renderer)
    generate_thumbnails
    generate_templates(renderer)
    copy_assets
    puts "Website generated in #{(Time.now - start_time)} seconds."
  end
end

# Get a parser, with a couple of registered streams as a demo.
def new_parser_with_streams
  Piccle::Parser.new.tap do |p|
    p.add_stream(Piccle::Streams::DateStream)
    p.add_stream(Piccle::Streams::LocationStream)
    p.add_stream(Piccle::Streams::EventStream)
    p.add_stream(Piccle::Streams::CameraStream)
    p.add_stream(Piccle::Streams::KeywordStream)
  end
end

# Load all the photos, and parse them all.
def parse_photos(parser)
  Piccle::Photo.all.each do |p|
    parser.parse(p)
  end
  parser.load_events
  parser.order
end

# Given a parser object, generate some HTML index pages from the data it contains.
def generate_html_indexes(parser, renderer)
  puts "    ... generating HTML indexes ..."
  print "        ... generating main index ... "
  File.write("generated/index.html", renderer.render_main_index)
  puts "Done."

  parser.subsections.each do |subsection|
    if parser.subsection_photo_hashes(subsection).any?
      subdir = "generated/#{subsection.join("/")}"
      print "        ... generating #{subdir} index ... "
      FileUtils.mkdir_p(subdir)
      File.write("#{subdir}/index.html", renderer.render_index(subsection))
      puts "Done."
    end
  end
end

# Given a parser object, generate Atom feeds for everything, and all substreams.
def generate_rss_feeds(parser, renderer)
  if Piccle::CONFIG.atom?
    puts "    ... generating Atom feeds ..."
    print "        ... generating main Atom feed ... "
    File.write("generated/feed.atom", renderer.render_feed)
    puts "Done."

    parser.subsections.each do |subsection|
      if parser.subsection_photo_hashes(subsection).any?
        subdir = "generated/#{subsection.join("/")}"
        print "        ... generating #{subdir} feed ... "
        FileUtils.mkdir_p(subdir)
        File.write("#{subdir}/feed.atom", renderer.render_feed(subsection))
        puts "Done."
      end
    end
  else
    puts "    Not generating RSS feeds, because no home URL is set."
  end
end

# Given a parser object, generate photo pages from the data it contains.
def generate_html_photos(parser, renderer)
  puts "    ... generating HTML photo pages ..."
  parser.photo_hashes.each do |hash|
    print "        ... generating canonical page for #{hash}... "
    File.write("generated/#{hash}.html", renderer.render_photo(hash))
    puts "Done."

    parser.links_for(hash).each do |selector|
      destination_page = "generated/#{selector.join('/')}/#{hash}.html"
      print "            ... generating stream page #{destination_page}..."
      File.write(destination_page, renderer.render_photo(hash, selector))
      puts "Done."
    end
  end
end

def generate_json(parser, _renderer)
  puts "    ... generating JSON files..."
  FileUtils.mkdir_p("generated/json")
  File.write("generated/json/all.json", parser.data.to_json)
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

def generate_templates(_renderer)
  puts '    ... generating templates...'
  FileUtils.mkdir_p('generated/js/')
  File.write('generated/js/index.handlebars.js', Piccle::TemplateHelpers.compile_template('index'))
  File.write('generated/js/show.handlebars.js', Piccle::TemplateHelpers.compile_template('show'))
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
