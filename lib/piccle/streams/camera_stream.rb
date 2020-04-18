require 'json'

# Browse photos by camera.
class Piccle::Streams::CameraStream
  def namespace
    "by-camera"
  end

  # Standard method called by the parser object. Returns a hash of photos by subcategory.
  def data_for(photo)
    camera_name = photo.camera_name || "unknown"
    {
      namespace => {
      :friendly_name => "By Camera",
      :interesting => false,
      camera_name => {
        friendly_name: "By Camera – #{camera_name}",
        photos: [photo.md5]
      },
    }
    }
  end

  # Standard method called by the parser object. Gives this stream an option to re-order its data. The stream is on
  # its honour to only meddle within its own namespace.
  def order(data)
    data[namespace] = data[namespace].sort_by { |k, v| k.is_a?(String) ? data.dig(namespace, k, :photos)&.length : 0 }.reverse.to_h
    data
  end
end
