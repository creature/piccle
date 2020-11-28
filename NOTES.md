# Priorities/things to do next 

## Right now! 

- Fix pagination spacing on the left hand side (after merging branch down) 
- Fix location display (mobile vs. desktop)
- Generate an OpenGraph image.

## Bugs
- Don't fail horribly if there are no images.
  - More useful error output if the given images directory does not exist.
- Should generate left/right hand side margins, even if there's no pagination link to put in there.


## Improvements

- Figure out what's causing some photo pages to slow down (and speed it up)
  - I think this is just calling out to a JS templating library (that uses V8 to render)
    - Switching to handlebars-ruby requires adding support for {with} and {lookup}
- Add ordering to all the various substreams. Almost done, apart from sorting days and months in the datestream.
- Generate an RSS feed.
- Add opengraph tags.
  - Requires configuring a URL for it.
- Update the photo update method so it also REMOVES keywords from files.
  - Store changed MD5 hashes, generate redirect pages for those.
- Add a cleanup function that removes old images/HTML.
- Make keywords case insensitive.
- Write a readme.
- Add "collapsed" view for events so they show up in one tile. 
- Add links to event tiles that link to the event page.
- Maybe combine substream path with include prefix? So we don't have to do two {{foo}}{{bar}} on every link.
- Put current stream first on photo page
- Update nav to render subnav too, for current section.
- Finish commenting the BaseStream.

## Gotchas
- Add option to regenerate entire site, or just changed photos.
  - Basically impossible! Even if a photo hasn't changed, the navigation items/stream neighbours might have changed. 
  - We'd have to cache the rendering context for each photo in the DB to determine whether we should regenerate it or not. 
  - Might as well just regenerate the page.

----- All the notes below are kind of outdated ------

- Remove all raw sqlite3 access from piccle.rake
- Look at doing some fancy JS lazy-loading??
  - Write an actual readme

- Remove previous DB (and generated files??) when we generate a site.

- JS slideshow at the top of the index page??
- Convert database.rake tasks over to the Sequel way of doing things
- Our current find-or-create for photos relates to the file name/path. It should probably use that, and/or the MD5. 
- Focal length is currently available as a fraction in the EXIF, but we're storing it as a float. Maybe we'd like to store it as a fraction instead?
- Add face detection, add perceptual hashing


# Development notes

- The EXIF tag calls the camera model "model", but in the DB schema we called it "camera_name". We might want to unify this.
  - NB. Sequel will throw a wobbly if we use "model" as a method name.
- Add a meaningful "alt" tag in the photo thumbnail.
- Did we break the update-the-database-for-existing-file functionality when we converted it over to Sequel? Look at the rake photos::update_db task to be sure.

- Each stream really needs to be able to generate:
  - individual photo pages (that are basically the normal photo pages, but they indicate its current position and the next/previous image, potentially with a stream of other images to jump to), 
  - Index pages, that show that particular pool's photo. 
- Streams should maybe be able to generate "top-level" pages, so we could have paths like "example.com/2008" rather than "example.com/by-date/2008".

- Potential way of doing pre-pass: 
  - Read each photo metadata into a hash
  - Pass each photo data, in turn, into a "stream" 
  - Each stream returns a hash to be merged into a main one, with keys for each photo by MD5.

# Misc todo
- Use a SASS preprocessor for the CSS generation
- Do some kind of live loading for development, so we don't have to regenerate the whole site to see our web changes. 
- Use a presenter to wrap our Photo object, rather than template_FOO methods?
