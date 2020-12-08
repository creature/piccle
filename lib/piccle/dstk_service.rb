require 'httparty'
require 'tmpdir'

# A little wrapper around the Data Science Toolkit. We use this for geocoding lat/long pairs of photos.
module Piccle
  class DstkService
    def initialize(tmpdir = nil)
      @tmpdir = tmpdir || File.join(Dir.tmpdir, "piccle", "location_cache")
    end

    # See if we have a lat/long in the Piccle database already. If so, we return it; otherwise, we create it.
    # Either way, you should get a Piccle::Location back.
    def location_for(photo)
      unless location = Piccle::Location.find(latitude: photo.latitude, longitude: photo.longitude)
        result = cached_coords2politics(photo.latitude, photo.longitude)
        if result
          result = JSON.parse(result)
          country = extract_field('country', result)
          state = extract_field('state', result)
          city = extract_field('city', result)
          puts "        Found #{[city, state, country].compact.join(", ")} from the Data Science Toolkit API."
          location = Piccle::Location.create(latitude: photo.latitude, longitude: photo.longitude, city: city, state: state, country: country)
        else
          puts "        Couldn't retrieve any location data for this photo."
        end
      end
      location
    end

    protected

    # Looks up a lat/long via the data science toolkit. We cache the API response in a temporary directory because it's
    # pretty slow.
    def cached_coords2politics(lat, lng)
      filename = File.join(@tmpdir, "#{lat}_#{lng}.json")
      FileUtils.mkdir_p(@tmpdir)
      if File.exists?(filename)
        File.read(filename)
      else
        response = HTTParty.get("http://www.datasciencetoolkit.org/coordinates2politics/#{lat}%2c#{lng}")
        if response.code >= 200 && response.code < 300
          File.write(filename, response.body)
          response.body
        end
      end
    rescue Net::OpenTimeout => e
      STDERR.puts "Error: couldn't lookup latitude/longitude on the Data Science Toolkit: #{e}"
      nil
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
  end
end
