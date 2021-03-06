# Priorities/things to do next 

## Roadmap

v0.2
- Render subnav (ie. if you're in 2020 view, it'll show the months)
- Show most recently added photos

v0.3
- Track hash changes, generate redirects and htaccess file
- Better display of streams on photo show page

v0.4
- Client-side rendering

v0.5
- Section browse pages


## Bugs
- Don't fail horribly if there are no images.
  - More useful error output if the given images directory does not exist.
- Figure out timezones around collapsed events


## Improvements

- Add "section browse" pages?
- Collapse "collapsed" sections everywhere, EXCEPT that particular stream.
- Add ordering to all the various substreams. Almost done, apart from sorting days and months in the datestream.
- Store changed MD5 hashes, generate redirect pages for those.
- Add a cleanup function that removes old images/HTML.
- Can we detect fixed focal length cameras in the metadata? 
- Maybe combine substream path with include prefix? So we don't have to do two {{foo}}{{bar}} on every link.
- Put current stream first on photo page
  - Generally improve the stream display on photo page. Filter out samey streams, maybe only show a maximum of 4?
- Update nav to render subnav too, for current section.
- Finish commenting the BaseStream.

## Gotchas
- Add option to regenerate entire site, or just changed photos.
  - Basically impossible! Even if a photo hasn't changed, the navigation items/stream neighbours might have changed. 
  - We'd have to cache the rendering context for each photo in the DB to determine whether we should regenerate it or not. 
  - Might as well just regenerate the page.

----- All the notes below are kind of outdated ------

- JS slideshow at the top of the index page??
- Our current find-or-create for photos relates to the file name/path. It should probably use that, and/or the MD5. 
- Focal length is currently available as a fraction in the EXIF, but we're storing it as a float. Maybe we'd like to store it as a fraction instead?

# Development notes

- Add a meaningful "alt" tag in the photo thumbnail.

- Streams should maybe be able to generate "top-level" pages, so we could have paths like "example.com/2008" rather than "example.com/by-date/2008".

# Misc todo
- Use a SASS preprocessor for the CSS generation
- Do some kind of live loading for development, so we don't have to regenerate the whole site to see our web changes. 
