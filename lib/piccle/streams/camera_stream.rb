# frozen_string_literal: true

# Browse photos by camera.
class Piccle::Streams::CameraStream < Piccle::Streams::BaseStream
  def namespace
    "by-camera"
  end

  def data_for(photo)
    {
      namespace => {
        :friendly_name => "By Camera",
        :interesting => false,
        slugify(camera_name(photo)) => {
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
      selector: [namespace, slugify(camera_name(photo))]
    }]
  end

  protected

  def camera_name(photo)
    photo.camera_name || "unknown"
  end
end
