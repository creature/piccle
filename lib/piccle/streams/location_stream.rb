# frozen_string_literal: true

# Enables browsing photos by location.
class Piccle::Streams::LocationStream < Piccle::Streams::BaseStream
  def namespace
    "by-location"
  end

  def data_for(photo)
    data = {}
    if photo.country
      data = { namespace => {
               :friendly_name => "By Location",
               :interesting => false,
               photo.country.downcase => {
                 :friendly_name => photo.country,
                 :interesting => true,
                 :photos => [photo.md5]
               },
             }}
      if photo.state
        data[namespace][photo.country.downcase][photo.state.downcase] = {
          :friendly_name => photo.state,
          :interesting => false,
          :photos => [photo.md5]
        }

        if photo.city
          data[namespace][photo.country.downcase][photo.state.downcase][photo.city.downcase] = {
            :friendly_name => photo.city,
            :interesting => false,
            :photos => [photo.md5]
          }
        end
      end
    end

    data
  end

  def metadata_for(photo)
    metadata = []

    if photo.country
      metadata << { friendly_name: photo.country, type: :location_country, selector: [namespace, photo.country.downcase] }

      if photo.state
        metadata << { friendly_name: photo.state, type: :location_state, selector: [namespace, photo.country.downcase, photo.state.downcase] }

        if photo.city
          metadata << { friendly_name: photo.city, type: :location_city, selector: [namespace, photo.country.downcase, photo.state.downcase, photo.city.downcase] }
        end
      end
    end
    metadata
  end
end
