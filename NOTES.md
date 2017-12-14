# Development notes

- The EXIF tag calls the camera model "model", but in the DB schema we called it "camera_name". We might want to unify this.
- Add a meaningful "alt" tag in the photo thumbnail.
- Remove byebug from the dependencies before publishing this as a gem (in the Gemspec and in lib/piccle.rb).
