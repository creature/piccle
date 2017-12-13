# Development notes

- The EXIF tag calls the camera model "model", but in the DB schema we called it "camera_name". We might want to unify this.
- Pull out "photo_data.db" into a constant in our Piccle module.
- Add a meaningful "alt" tag in the photo thumbnail.
