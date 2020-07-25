# Piccle

Piccle is a static photo gallery generator. Purposefully designed with no admin interface, it builds the gallery from 
the metadata embedded in your image files. You can see a Piccle-driven gallery at https://photography.alexpounds.com/.

Piccle is my current main side project, but it's something I work on for fun. 


## A Warning About Privacy 

Piccle does not strip any of the metadata from your photos; be aware of what you're putting on the internet. Location 
metadata can reveal where you live or work, and is automatically added to photos by most phones. Your photos may also
contain contact info or real names - either your own ([eg.](http://fujifilm-dsc.com/en/manual/x100f/menu_setup/save_data_set-up/index.html#copyright_info))
or [that of your subjects](https://www.iptc.org/std/photometadata/documentation/userguide/#_persons_depicted_in_the_image) - 
though these are unlikely to be added unless you set them up first. 

## Getting started

Eventually Piccle will be available via Rubygems. For now, it's available via Github. 

1. Place your photos within the `images/` directory. 
1. Run `rake piccle:generate`. 
1. Take the output in `generated/` and deploy it to your web server of choice.

## Metadata Used

* **Title** and **description** are shown on photo pages, as are **shutter speed**, **aperture**, and **ISO**. 
* **Camera model** is shown on photo pages, and browsable. 
* **Date taken** is shown on photo pages, and is browsable at the year, month, and day level. 
* **Keywords** are shown, and exposed as "topics". 
* **Location** is shown. If your photos have a city/state/country specified in their data, then that's used; otherwise, 
  Piccle will attempt to geocode them based on embedded latitude/longitude.


-------

## Credits

Geolocation is provided by the free [Data Science Toolkit API](http://www.datasciencetoolkit.org/developerdocs#coordinates2politics).
The test images are public domain images by [Sasin Tipchai](https://pixabay.com/photos/elephant-animals-asia-large-1822636/), 
[Timo Schlüter](https://pixabay.com/photos/kingfisher-bird-blue-plumage-1905255/), and 
[Jill Wellington](https://pixabay.com/photos/spring-bird-bird-spring-blue-2295431/). 


## License

Piccle is licensed under the [Affero GPL v3](https://www.gnu.org/licenses/agpl-3.0.en.html).


## Contributing

I have fairly firm ideas about where I want to take Piccle, so if you want to contribute features please talk to me 
first! Bugfixes and test cases are welcomed, especially if you can include a public-domain photo that illustrates the 
bug.

------

## Suggested Tools

I am resisting the urge to write my own metadata manager until I consider Piccle complete. I haven't found an ideal 
tool for managing metadata yet, but here are some options:

### Adobe Bridge

Pros
: Available for free, without a paid Creative Cloud subscription
: Lets you build a library of keywords, with a nested heirarchy, so it's easier to use a set of standard tags with your photos
: Can [edit titles, descriptions, and locations](https://helpx.adobe.com/ca/bridge/using/metadata-adobe-bridge.html)
: Good filtering support: it's easy to find pictures lacking metadata

Cons
: You still need a Creative Cloud account to download it
: You must install the Adobe Creative Cloud stuff to get Bridge
: Can't place photos on a map for adding latitude/longitude.

### macOS Preview

Pros
: If you use macOS you already have it
: Access the inspector (⌘-I or File → Inspect) and choose the "Keywords" panel to add/remove keywords

Cons 
: Can't edit title, description, or location
: Can't build a library of tags

### Affinity Photo

Pros
: Lets you edit titles, descriptions, locations, keywords, and add latitude/longitude via a map
: Is generally a delightful image editor

Cons
: Longwinded for bulk edits: open photo, switch to Develop mode, change to metadata tab, switch between "File" and "IPTC (Image)" sections
: No tag library - you must type in a comma-separated string


## Automation

You can run Piccle by hand, but it's also ideal for automation. I use Piccle with macOS' built-in [Automator](https://support.apple.com/en-gb/guide/automator/welcome/mac)
tool. A [folder action](https://support.apple.com/en-gb/guide/automator/aut7cac58839/2.10/mac/10.15) watches Piccle's 
`images` directory for added files; when a file is added, automator runs `rake piccle:generate` and runs [`rsync`](https://wiki.archlinux.org/index.php/Rsync)
to copy the generated files to my web server. Zero-click publishing! When I finish editing an image I save a JPEG to 
Piccle's directory, and it's published automatically in the background.




------

## Philosophy

Most photo sharing websites don't support the conversations I naturally have about photography - meaning you can't 
take introductions like these:

* "I'm really into portraits at the moment."
* "I just got a new camera, and it's great."
* "I took a trip to Norway last year, and had a great time."

And append "Here, let me show you some pics" in a couple of clicks. Instagram only has hashtags, and you can't filter
your own photos by hashtag. 500px gives you some organisational tools (like albums), but puts the onus on you to file
the photos in each album. (Flickr has [some amazing search features](https://www.flickr.com/search/advanced), but limits
how many photos you can upload for free and doesn't mesh with a [POSSE self-hosting ideal](https://indieweb.org/POSSE)).


## Architecture

Piccle is built around two phases: 

1. Reading your photos, and building an [Sqlite]() database of the metadata. 
1. Generating a site. This has two co-operating parts:
    1. A parser, which reads the cached photo data and builds an intermediate data structure with just the data needed
       to build the site. 
    1. An extractor, which pulls out data from that data structure in a way useful for the frontend.
    1. There's also a renderer, capable of generating "index" pages and "show" pages. This doesn't do anything 
       complicated, though; it's basically a proxy between the extractor and a template. 

_Streams_ are another key concept. 
