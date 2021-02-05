# frozen_string_literal: true

# Browse photos by person.
class Piccle::Streams::PersonStream < Piccle::Streams::BaseStream
  def namespace
    "by-person"
  end

  def data_for(photo)
    result = { namespace => { :friendly_name => "By Person", :interesting => true, :min_for_nav => 2 } }
    photo.people.each do |person|
      result[namespace][slugify(person.name)] = { friendly_name: person.name, interesting: true, photos: [photo.md5] }
    end
    result
  end
end
