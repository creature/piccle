# Priorities/things to do next 

## Roadmap

v0.1
- Test it works on other computers
- Show focal length in metadata. I wonder if we can see whether a camera has a fixed lens in the metadata?
- Downcase location names
- Better iPad display
- Update readme
- Remove "noindex" tag in header.

v0.2
- Paginated indexes
- Render subnav (ie. if you're in 2020 view, it'll show the months)
- People browser
- Show most recently added photos

v0.3
- Track hash changes, generate redirects and htaccess file
- Collapsible events on the front page (maybe)
- Better display of streams on photo show page

v0.4
- Client-side rendering


## Bugs
- Don't fail horribly if there are no images.
  - More useful error output if the given images directory does not exist.


## Improvements

- Add ordering to all the various substreams. Almost done, apart from sorting days and months in the datestream.
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

- JS slideshow at the top of the index page??
- Convert database.rake tasks over to the Sequel way of doing things
- Our current find-or-create for photos relates to the file name/path. It should probably use that, and/or the MD5. 
- Focal length is currently available as a fraction in the EXIF, but we're storing it as a float. Maybe we'd like to store it as a fraction instead?

# Development notes

- The EXIF tag calls the camera model "model", but in the DB schema we called it "camera_name". We might want to unify this.
  - NB. Sequel will throw a wobbly if we use "model" as a method name.
- Add a meaningful "alt" tag in the photo thumbnail.

- Streams should maybe be able to generate "top-level" pages, so we could have paths like "example.com/2008" rather than "example.com/by-date/2008".

# Misc todo
- Use a SASS preprocessor for the CSS generation
- Do some kind of live loading for development, so we don't have to regenerate the whole site to see our web changes. 
