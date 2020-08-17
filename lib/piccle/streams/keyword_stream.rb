# frozen_string_literal: true

# Browse photos by keyword.
class Piccle::Streams::KeywordStream < Piccle::Streams::BaseStream
  def namespace
    "by-topic"
  end

  # Standard method called by the parser object. Returns a hash that contains the data to merge for the given photo.
  def data_for(photo)
    result = { namespace => {
               :friendly_name => "By Topic",
               :interesting => true
             }}
    photo.keywords.each do |kw|
      result[namespace][slugify(kw.name)] = { friendly_name: kw.name, interesting: true, photos: [photo.md5] }
    end
    result
  end

  def metadata_for(photo)
    photo.keywords.map { |kw| { friendly_name: kw.name, type: :keyword, selector: [namespace, slugify(kw.name)] } }
  end
end
