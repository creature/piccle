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
      camera_name => {
        photos: [photo.md5]
      },
    }
    }
  end

  def navigation_items
    cameras.map { |camera| [camera, html_path_for(camera)] }
  end

  def generate_json(root_path)

  end

  def generate_html(root_path)

  end

  def html_path_for(camera)
    url_safe_camera = camera.downcase.gsub(/[_ ]/, "-")
    "#{namespace}/#{url_safe_camera}.html"
  end

  protected

  def cameras
    # TODO: make this waaaaaay less long and ugly.
    @cameras ||= Piccle::Photo.db['SELECT camera_name, COUNT(*) AS photo_count FROM photos GROUP BY camera_name ORDER BY photo_count DESC'].all.map { |el| el.values.first }
  end
end
