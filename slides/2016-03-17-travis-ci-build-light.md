---
layout: slide
theme: blog
transition: slide

date: 2016-03-17
title: Tracking Travis Builds with RGB LEDs
description: Nodebots workshop on creating a physical build indicator for
 Travis CI with IFTTT, Johnny-Five, and ngrok.

permalink: /slides/nodebots-travis-ci
---

<section data-markdown>
## Build A Johnny-Five Power Status Light For Your Travis CI Project

NodeBotsSF | March 17, 2016

</section>

<section data-markdown>
### Hi, I'm Cat 😸

I'm on Twitter... [@_cathaines](https://twitter.com/_cathaines)

**♥️ I really love hardware that's on that web ♥️**

</section>

<section data-markdown>

**♥️ I love *really simple* hardware that's on that web ♥️**

</section>

<section data-markdown>

![Press for Pizza](../../assets/imgs/slides/nodebots-travis-ci/imp-button.jpeg)

</section>

<section data-markdown>

![ISS Overhead](../../assets/imgs/slides/nodebots-travis-ci/iss-overhead.jpeg)

</section>

<section data-markdown>

![Circuit](../../assets/imgs/slides/nodebots-travis-ci/circuit.jpeg)

</section>

<section data-markdown>
### What are we actually doing..

- **A Johnny-Five Powered RGB LED Server**
    + This probably sounds a lot cooler than it actually is
- **Creating a basic Travis CI configuration**
    + Scripts to change the LEDs color
- **Creating a simple IFTTT Integration**
    + This isn't really required, but adds flexibility

</section>

<section data-markdown>
### Travis CI

![Build Status](https://travis-ci.org/cat-haines/cathaines.com.svg?branch=master)

[Travis CI](https://travis-ci.org) is a continuous integration tool that works well with [GitHub](https://github.com) and can be easily setup to build and test a project each time a commit is pushed to GitHub.
</section>

<section data-markdown>

![Travis Dashboard](../../assets/imgs/slides/nodebots-travis-ci/travis-dashboard.png)

</section>

<section data-markdown>
### Before we "start"

- Fork the project - [github.com/cat-haines/travis-light](https://github.com/cat-haines/travis-light)
- Create a Travis CI account - [travis-ci.org](https://travis-ci.org)
- Enable the Travis Integration - [travis-ci.org/profile](https://travis-ci.org/profile)

</section>

<section data-markdown>
### .travis.yml defines the build

```yml
# .travis.yml

sudo: false
language: node_js

before_install:
 - chmod +x /scripts/*
 - ./scripts/before_install.sh

install:        ./scripts/install.sh
script:         ./scripts/script.sh
```

</section>

<section data-markdown>
### ./scripts folder has the details

*before_install.sh*
```bash
#!/usr/bin/env bash
set -e # halt script on error

echo "Before Install Step..."
```

*install.sh*
```bash
#!/usr/bin/env bash
set -e # halt script on error

echo "Install Step..."
```

</section>

<section data-markdown>

### Let's trigger a build

- Modify a file
- Commit the changes
- Push the changes to GitHub
- Enjoy the show (live build logs)

</section>

<section data-markdown>

### What about IFTTT??

[IFTTT](http://ifttt.com) (If this then that) makes is super simple to connect your favourite [apps and web services](https://ifttt.com/channels)!

</section>

<section data-markdown>

### Your First Recipe?

- Enable the Maker Channel - [iftt.com/maker](http://ifttt.com/maker)
- Create a Recipe - [ifttt.com/myrecipes/personal/new](https://ifttt.com/myrecipes/personal/new)
    + **This:** Maker Channel
        + **Event Name:** "build"
    + **That:** SMS
        + **Message:** "Build {%raw%}{{Value1}}{% endraw %} completed with status {%raw%}{{Value2}}{% endraw %}"

</section>

<section data-markdown>

<section>