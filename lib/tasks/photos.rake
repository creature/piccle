require 'fileutils'
require 'httparty'
require 'json'
require 'piccle'

namespace :photos do
  desc "List out photo attributes"
  task :list do
    Piccle::Photo.all.each do |photo|
      puts "#{photo.original_photo_path}:"
      puts "    Width: #{photo.width}"
      puts "    Height: #{photo.height}"
      puts "    Camera: #{photo.model}"
      puts "    Taken at: #{photo.taken_at}"
      puts "    MD5: #{photo.md5}"
      puts "--------------------------"
    end
  end

  desc "Process locations for photos"
  task :update_locations do
    Piccle::Photo.all.each do |photo|
      # Is this photo fully geocoded? That is, does it have lat/long/city/state/country?
      puts "Updating location data for #{photo.file_name}..."
      if photo.geocoded?
        puts "    Already geocoded."
        # If so, do we have it in our location cache?
        unless Piccle::Location.find(latitude: photo.latitude, longitude: photo.longitude)
          Piccle.Location.create(latitude: photo.latitude, longitude: photo.longitude, city: photo.city,
                                 state: photo.state, country: photo.country)
        end

      # Does it have just a lat/long? If so, is there a location record we can use to geocode it?
      elsif photo.latitude && photo.longitude
        puts "    Looking up place names for #{photo.latitude}, #{photo.longitude}"
        # Can we look this up now in our cache?
        if location = Piccle::Location.find(latitude: photo.latitude, longitude: photo.longitude)
          puts "        Found #{[location.city, location.state, location.country].compact.join(", ")} in the database."
          unless photo.update(city: location.city, state: location.state, country: location.country)
            puts "        Couldn't save data: #{photo.errors.inspect}"
          end
        else
          # If not, can we look it up now?
          result = JSON.parse(cached_coords2politics(photo.latitude, photo.longitude))
          country = extract_field('country', result)
          state = extract_field('state', result)
          city = extract_field('city', result)
          puts "        Found #{[city, state, country].compact.join(", ")} from the Data Science Toolkit API."
          Piccle::Location.create(latitude: photo.latitude, longitude: photo.longitude, city: city, state: state, country: country)
          puts "        Couldn't save data: #{photo.errors.inspect}" unless photo.update(city: city, state: state, country: country)
        end
      else
        places = [photo.city, photo.state, photo.country].compact
        if places.any?
          puts "    Photo has metadata labels for #{places.join(", ")}."
        else
          puts "    No geo information in this photo's metadata."
        end
      end
    end
  end
end

# Looks up a lat/long on the data science toolkit.
def cached_coords2politics(lat, lng)
  filename = "tmp/dstk/coordinates2politics/#{lat}_#{lng}.json"
  FileUtils.mkdir_p("tmp/dstk/coordinates2politics")
  if File.exists?(filename)
    File.read(filename)
  else
    response = HTTParty.get("http://www.datasciencetoolkit.org/coordinates2politics/#{lat}%2c#{lng}")
    if response.code >= 200 && response.code < 300
      File.write(filename, response.body)
      response.body
    end
  end
end

# DTSK may return several items of the same friendly_type. We want to find the "biggest" place, and only get back one.
def extract_field(field, hash)
  relevant_data = hash.first["politics"].select { |x| x['friendly_type'] == field && x['type'].start_with?('admin') }
  sorted_relevant_data = relevant_data.sort_by do |x|
    x["type"].match(/(\d+)/)[0].to_i
  end
  if sorted_relevant_data.any?
    sorted_relevant_data.first['name']
  else
    nil
  end
end
