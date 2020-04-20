require 'json'

# Browse photos by camera.
class Piccle::Streams::CameraStream
  def namespace
    "by-camera"
  end

  # Standard method called by the parser object. Returns a hash of photos by subcategory.
  def data_for(photo)
    {
      namespace => {
        :friendly_name => "By Camera",
        :interesting => false,
        camera_name(photo) => {
          friendly_name: camera_name(photo),
          photos: [photo.md5]
        },
      }
    }
  end

  def metadata_for(photo)
    [{
      friendly_name: camera_name(photo),
      type: :camera,
      selector: [namespace, camera_name(photo)]
    }]
  end

  # Standard method called by the parser object. Gives this stream an option to re-order its data. The stream is on
  # its honour to only meddle within its own namespace.
  def order(data)
    data[namespace] = data[namespace].sort_by { |k, v| k.is_a?(String) ? data.dig(namespace, k, :photos)&.length : 0 }.reverse.to_h
    data
  end

  protected

  def camera_name(photo)
    photo.camera_name || "unknown"
  end
end
