# Priorities/things to do next 
- Right now, you're in the middle of doing things in a parse-then-generate cycle. The parser is probably fully working. 
  It also generates subindex pages, and canonical pages for photos. These are reasonably well-advanced.
  Your sensible next steps will probably be: 
  - Fix change detection (files aren't being reingested when they change.)
  - Also generate individual photo pages for each facet.
  - Add some breadcrumbs or similar to the subindex pages that show where you are in the nav.
  - Show a faceted stream on the photo page.  (In progress)
    - Add labels to each facet. 
    - Filter out small facets (< 3 photos?)
    - Show keywords as tags on photo page.
  - Generate an RSS feed.
  - Add opengraph tags.
  - Add link prev next on photo pages.
  - Add link back to home page on photo page.
  - Figure out what to do about 1970 datestamp.


----- All the notes below are kind of outdated ------

- Empty test DB between runs. 

- Continue fleshing out the actual photo page.
- Remove all raw sqlite3 access from piccle.rake
- Look at doing some fancy JS lazy-loading??
- Finish off the path_generators helper
  - Figure out how to generate paths neatly. Sometimes we need to generate Sinatro paths; sometimes we want them all relative for file:// serving; sometimes we want static files but designed to be served from a web server. 
    All of these must work. 
  - Write an actual readme

- Remove previous DB (and generated files??) when we generate a site.

- JS slideshow at the top of the index page??
- Convert database.rake tasks over to the Sequel way of doing things
- Running rake db:initialise no longer works, and we're moving over to using Sequel migrations for DB access. Fix things up so that running the rake task uses the Sequel migrations. http://sequel.jeremyevans.net/rdoc/files/doc/migration_rdoc.html#label-Running+migrations+from+a+Rake+task
- Our current find-or-create for photos relates to the file name/path. It should probably use that, and/or the MD5. 
- Focal length is currently available as a fraction in the EXIF, but we're storing it as a float. Maybe we'd like to store it as a fraction instead?
- Convert some string munging to build paths over to use File.join instead.
- Teach the Sinatra app to interface with feature streams.
- Generate rel=canonical links?
- Navigation (previous/ext)
- Unit tests
- Add face detection, add perceptual hashing


# Development notes

- The EXIF tag calls the camera model "model", but in the DB schema we called it "camera_name". We might want to unify this.
  - NB. Sequel will throw a wobbly if we use "model" as a method name.
- Add a meaningful "alt" tag in the photo thumbnail.
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

- Each stream really needs to be able to generate:
  - individual photo pages (that are basically the normal photo pages, but they indicate its current position and the next/previous image, potentially with a stream of other images to jump to), 
  - Index pages, that show that particular pool's photo. 
- Streams should maybe be able to generate "top-level" pages, so we could have paths like "example.com/2008" rather than "example.com/by-date/2008".

- Potential way of doing pre-pass: 
  - Read each photo metadata into a hash
  - Pass each photo data, in turn, into a "stream" 
  - Each stream returns a hash to be merged into a main one, with keys for each photo by MD5.

# Misc todo
- Don't use display: inline-block for the nav/main photo section, use Flexbox instead
- Use a SASS preprocessor for the CSS generation
- Do some kind of live loading for development, so we don't have to regenerate the whole site to see our web changes. 
- Use a presenter to wrap our Photo object, rather than template_FOO methods?
