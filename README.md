# Piccle

Piccle is a static photo gallery generator. Purposefully designed with no admin interface, it builds the gallery from the metadata embedded in your image files.

You can see a Piccle-driven gallery at https://photography.alexpounds.com/.


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


## Configuration


## Installation

## Usage

1. Place your photos within the `images/` directory. 
1. Run `rake piccle:generate`. 
1. Take the output in `generated/` and deploy it to your web server of choice.


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
