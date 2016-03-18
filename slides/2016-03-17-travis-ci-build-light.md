---
layout: slide
theme: blog
transition: slide

title: Build A Johnny-Five Powered Status Light For Your Travis CI Project
event: NodeBotsSF
date: 2016-03-17

description: Nodebots workshop on creating a physical build indicator for
 Travis CI with IFTTT, Johnny-Five, and ngrok.

permalink: /slides/nodebots-travis-ci
---

{% include title-slide.md %}
<section data-markdown>
### 😸 Hi, I'm Cat 😸

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

![Circuit](../../assets/imgs/slides/nodebots-travis-ci/circuit.jpg)

</section>

<section data-markdown>
### What are we doing tonight?

- Configure a basic [Travis CI](https://travis-ci.org) build
- Create [IFTTT](https://ifttt.com) recipes for success & failure
- Write a [Johnny-Five](https://github.com/rwaldron/johnny-five) powered RGB LED server
- Use [ngrok](https://ngrok.com) to expose our RGB LED server
- Connect [EVERYTHING](#) and celebrate 🎉

</section>


<section data-markdown class="plain">
### Wait, who is this Travis fellow?

[Travis CI](https://travis-ci.org) is a continuous integration tool that enables developers to easily build, test, and deploy their code on an ongoing basis.

![Build Status](../../assets/imgs/slides/nodebots-travis-ci/build-passing.svg)

</section>

<section data-markdown class="plain">

![Google Search](../../assets/imgs/slides/nodebots-travis-ci/google.png)

</section>

<section data-markdown>
### Configure a basic Travis CI Build

- Fork the [Johnny-Five Build Light](https://github.com/cat-haines/johnny-five-build-light) project
  + github.com/cat-haines/johnny-five-build-light
- Create or log into your [Travis CI Account](https://travis-ci.org)
  + travis-ci.org
- [Enable the Travis Integration](https://travis-ci.org/profile) for the repo you forked
  + travis-ci.org/profile

</section>

<section data-markdown>

![Travis Profile](../../assets/imgs/slides/nodebots-travis-ci/travis-profile.png)

</section>

<section data-markdown>
### Configuring Build
We configure our Travis builds with a [.travis.yml](#) file:

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
### Starting a Build!

A build will be created each time we [push to any branch](#) in our project's GitHub repository. Let's start a build:

```bash
$ echo "echo Hello Johnny!" >> ./scripts/build.sh
$ git add ./scripts/build.sh
$ git commit -m "my first travis build"
$ git push origin master
```

</section>

<section data-markdown>

### Let's talk about IFTTT...

[IFTTT](http://ifttt.com) - If this then that - makes it super simple to connect your favourite [apps and web services](https://ifttt.com/channels)!

*(IFTTT still isn't JavaScript.. shhh)*

</section>

<section data-markdown>

### Your First Recipe?

- Create an [IFTTT Account](http://ifttt.com)
  + ifttt.com
- Enable the [Maker Channel](http://ifttt.com/maker) & note your `key`
  + ifttt.com/maker
- Create a [Recipe](https://ifttt.com/myrecipes/personal/new)
  + ifttt.com/myrecipes/personal/new
  + **IF THIS:** Maker Channel
    + *Event Name:* "build_started"
  + **Then THAT:** SMS
    + *Message:* "A Travis build just started!!"

</section>

<section data-markdown>

### And now for a bit of magic 🎩

```
$ echo "- IFTTT_KEY={your maker key}" >> .travis.yml
$ echo "curl https://maker.ifttt.com/trigger/\
build_started/with/key/\$IFTTT_KEY" >> ./scripts/before_install.sh
$ git add -A .
$ git commit -m "Magic"
$ git push origin master
```

* **NOTE**: Replace {your maker key} with the key.

</section>

<section data-markdown>

###Isn't this a nodebots meetup?

</section>

<section data-markdown>

![Circuit](../../assets/imgs/slides/nodebots-travis-ci/circuit.jpg)

</section>

<section data-markdown class="no-caps">
### `npm install --save johnny-five`

</section>

<section data-markdown>
### Hello, Rainbow 🌈

```js
// index.js
var five = require("johnny-five");
var board = new five.Board();

var rgb;

board.on("ready", function() {
  // Create an RGB LED ([RedPin, GreenPin, BluePin])
  rgb = new five.Led.RGB([11,10,9]);

  // Set the color, and switch between on/off every 500ms
  rgb.color("#2a1c31");
  rgb.strobe(500);
});
```

</section>

<section data-markdown>
### Making a Server

This probably isn't new to you...
```js
// bottom of index.js
var http = require("http");

var server = http.createServer(function(req, resp) {
  var url = req.url.toLowerCase();
  if (url.indexOf("/events/build/started") == 0) {
    resp.end("Build Started");
  } else if (url.indexOf("/events/build/success") == 0) {
    resp.end("Build Successful");
  } else if (url.indexOf("/events/build/failure") == 0) {
    resp.end("Build Failed");
  } else {
    resp.end("Unknown event");
  }
}).listen(8000);
console.log("Server listening on: http://localhost:8000");

```

</section>

<section data-markdown>
### Johnny-Five RGB LED Server

```
var server = http.createServer(function(req, resp) {
  if (!rgb) {
    resp.end("No board found...");
    return;
  }

  var url = req.url.toLowerCase();
  if (url.indexOf("/events/build/started") == 0) {
    rgb.color("#FFFF00");
    resp.end("Build Started");
  } else if (url.indexOf("/events/build/success") == 0) {
    rgb.color("#00FF00");
    resp.end("Build Successful");
  }
  // ...
});
```

</section>

<section data-markdown>
### Didn't You Mention ngrok

```
$ brew install ngrok
$ ngrok 8000

ngrok by @inconshreveable                         (Ctrl+C to quit)
                                                                   
Tunnel Status         online
Version               2.0.25/2.0.25
Region                United States (us)
Web Interface         http://127.0.0.1:4040
Forwarding            http://c4774e1a.ngrok.io -> localhost:8000
Forwarding            https://c4774e1a.ngrok.io -> localhost:8000
                                                                   
Connections           ttl     opn     rt1     rt5     p50     p90
                      0       0       0.00    0.00    0.00    0.00

```

*Secure introspectable tunnels to localhost!!!*

</section>

<section data-markdown>
### Putting it all together...

- Add [curl](#) commands to our build_success and build_failure scripts
- Create new [IFTTT recipes](https://ifttt.com/myrecipes/personal/new) that forward the requests to our ngrok server (via the *THAT Maker Channel*)
- Push a commit, and watch the [magic](#) happen!
</section>

<section data-markdown>

![Success!](http://i.giphy.com/q6QHDGE3X4EWA.gif)

</section>

<section data-markdown>
### 🏆 You Did It 🏆

Here's the [complete code](https://github.com/cat-haines/johnny-five-build-light/tree/final) for tonight's project.

</section>