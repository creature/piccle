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


------



## Suggested Tools



## Automation



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
