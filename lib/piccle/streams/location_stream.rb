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
               :interesting => true,
               photo.country => {
                 :friendly_name => photo.country,
                 :interesting => false,
                 :photos => [photo.md5]
               },
               :photos => [photo.md5]
             }}
      if photo.state
        data[namespace][photo.country][photo.state] = {
          :friendly_name => photo.state,
          :interesting => false,
          :photos => [photo.md5]
        }

        if photo.city
          data[namespace][photo.country][photo.state][photo.city] = {
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
      metadata << { friendly_name: photo.country, type: :location_country, selector: [namespace, photo.country] }
    end
    metadata
  end
end
