# Priorities/things to do next 
- Use MD5 hashes in filenames when generating files
- Don't regenerate thumbnails if one already exists
- Per-image display page
- Extract tags from files, and save them
  - Then display tags as categories on the site.
- Stop doing raw SQL and use something like the Sequel library instead.
- JS slideshow at the top of the index page??
- Config file, so users can define their own name/title/etc? 


# Development notes

- The EXIF tag calls the camera model "model", but in the DB schema we called it "camera_name". We might want to unify this.
- Add a meaningful "alt" tag in the photo thumbnail.
- Remove byebug from the dependencies before publishing this as a gem (in the Gemspec and in lib/piccle.rb).
