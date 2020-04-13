require 'json'

# Browse photos by keyword.
class Piccle::Streams::KeywordStream
  def namespace
    "by-topic"
  end

  # Standard method called by the parser object. Returns a hash that contains the data to merge for the given photo.
  def data_for(photo)
    result = { namespace => {
               :friendly_name => "By Topic"
             }}
    photo.keywords.each do |kw|
      result[namespace][kw.name] = { photos: [photo.md5] }
    end
    result
  end

  # Standard method called by the parser object. Gives this stream an option to re-order its data. The stream is on
  # its honour to only meddle within its own namespace.
  def order(data)
    data[namespace] = data[namespace].sort_by { |k, v| k.is_a?(String) ? data.dig(namespace, k, :photos)&.length : 0 }.reverse.to_h
    data
  end
end
