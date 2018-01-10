# Priorities/things to do next 
- Remove all raw sqlite3 access from piccle.rake
- Generate a "full-size" image size in our generated images
- Per-image display page (ie. make images clickable)
- Look at doing some fancy JS lazy-loading??

- Extract tags from files, and save them
  - Then display tags as categories on the site.
- JS slideshow at the top of the index page??
- Config file, so users can define their own name/title/etc? 
- Generate sidebar based on actual data, not just placeholder text
- Convert database.rake tasks over to the Sequel way of doing things


# Development notes

- The EXIF tag calls the camera model "model", but in the DB schema we called it "camera_name". We might want to unify this.
  - NB. Sequel will throw a wobbly if we use "model" as a method name.
- Add a meaningful "alt" tag in the photo thumbnail.
- Remove byebug from the dependencies before publishing this as a gem (in the Gemspec and in lib/piccle.rb).
- Did we break the update-the-database-for-existing-file functionality when we converted it over to Sequel? Look at the rake photos::update_db task to be sure.

# Misc todo
- Don't use display: inline-block for the nav/main photo section, use Flexbox instead
- Use a SASS preprocessor for the CSS generation
- Do some kind of live loading for development, so we don't have to regenerate the whole site to see our web changes. 
- Use a presenter to wrap our Photo object, rather than template_FOO methods?
