# Priorities/things to do next 
- Use MD5 hashes in filenames when generating files
- Per-image display page
- Extract tags from files, and save them
  - Then display tags as categories on the site.
- Stop doing raw SQL and use something like the Sequel library instead.
- JS slideshow at the top of the index page??
- Config file, so users can define their own name/title/etc? 
- Generate sidebar based on actual data, not just placeholder text


# Development notes

- The EXIF tag calls the camera model "model", but in the DB schema we called it "camera_name". We might want to unify this.
- Add a meaningful "alt" tag in the photo thumbnail.
- Remove byebug from the dependencies before publishing this as a gem (in the Gemspec and in lib/piccle.rb).

# Misc todo
- Don't use display: inline-block for the nav/main photo section, use Flexbox instead
- Use a SASS preprocessor for the CSS generation
- Do some kind of live loading for development, so we don't have to regenerate the whole site to see our web changes. 
