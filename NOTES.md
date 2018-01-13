# Priorities/things to do next 
- Image serving via Sinatra is MASSIVELY INSECURE and should be fixed up. 
- Finish off the path_generators helper
- Continue fleshing out the actual photo page.
- Pull out aperture, shutter speed, ISO, and image description into the photo DB
  - This might be a good time to figure out the logic for "If we have data already, amend it"
- Pull out site header and site footer into a partial
- Try to do "browse by stream"
- Remove all raw sqlite3 access from piccle.rake
- Look at doing some fancy JS lazy-loading??

- Extract tags from files, and save them
  - Then display tags as categories on the site.
- JS slideshow at the top of the index page??
- Config file, so users can define their own name/title/etc? 
- Generate sidebar based on actual data, not just placeholder text
- Convert database.rake tasks over to the Sequel way of doing things
- Running rake db:initialise no longer works, and we're moving over to using Sequel migrations for DB access. Fix things up so that running the rake task uses the Sequel migrations. http://sequel.jeremyevans.net/rdoc/files/doc/migration_rdoc.html#label-Running+migrations+from+a+Rake+task


# Development notes

- The EXIF tag calls the camera model "model", but in the DB schema we called it "camera_name". We might want to unify this.
  - NB. Sequel will throw a wobbly if we use "model" as a method name.
- Add a meaningful "alt" tag in the photo thumbnail.
- Remove byebug from the dependencies before publishing this as a gem (in the Gemspec and in lib/piccle.rb).
- Did we break the update-the-database-for-existing-file functionality when we converted it over to Sequel? Look at the rake photos::update_db task to be sure.

- Potential file structure: 

  + generated
  |-+ by-date
  | |- 2018
  | |- 2017
  | |- 2016
  |
  |-+ by-camera
    |- fuji-x100f
    |- canon-350d

# Misc todo
- Don't use display: inline-block for the nav/main photo section, use Flexbox instead
- Use a SASS preprocessor for the CSS generation
- Do some kind of live loading for development, so we don't have to regenerate the whole site to see our web changes. 
- Use a presenter to wrap our Photo object, rather than template_FOO methods?
