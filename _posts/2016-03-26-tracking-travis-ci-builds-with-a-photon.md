---
layout: post
title:  Tracking Travis CI Builds with a Photon
date:   2016-03-26 8:31
description:
 Track the status of your Travis CI builds with this super simple project!
categories:
- code
- travis
- nodebots
---

A couple weeks ago I ran a workshop at a [Nodebots meetup][meetup] about building a [Johnny-Five Powered Travis CI Build Indicator][slides]. One of the goals of the workshop was to introduce people to a bunch of cool tools they may or may not have used before.. [Travis CI][travis], [Johnny-Five][johnny-five], [IFTTT][ifttt], and [ngrok][ngrok].

But the best tools are often not the most intereting.. so today we're going to rebuild this project with a [Photon][photon], and with simplicity in mind.

<!-- more -->

## The Photon Side of Things

We're going to create a pretty standard circuit for an RGB LED, and flash our Proton with a tiny bit of code to control that LED through HTTP requests!

![Circuit](/assets/imgs/blog/2016-03-26/circuit.png)

```c
#define GREEN_PIN   D0
#define RED_PIN     D1
#define BLUE_PIN    D2

void setup() {
  // Configure pins and set defaults
  pinMode(RED_PIN,   OUTPUT);  digitalWrite(RED_PIN,   LOW);
  pinMode(GREEN_PIN, OUTPUT);  digitalWrite(GREEN_PIN, LOW);
  pinMode(BLUE_PIN,  OUTPUT);  digitalWrite(BLUE_PIN,  LOW);

  Spark.function("setcolor", setColor);
}

void loop() { }

void setLeds(int r, int g, int b) {
    analogWrite(RED_PIN,   constrain(r, 0, 255));
    analogWrite(GREEN_PIN, constrain(g, 0, 255));
    analogWrite(BLUE_PIN,  constrain(b, 0, 255));
}

int setColor(String color) {
    if (color.equalsIgnoreCase("off")) {
      setLeds(0, 0, 0);
    } else if (color.equalsIgnoreCase("green")) {
      setLeds(0, 255, 0);
    } else if (color.equalsIgnoreCase("yellow")) {
      setLeds(255, 255, 0);
    } else if (color.equalsIgnoreCase("red")) {
      setLeds(255, 0, 0);
    } else {
      return -1;  //  Unknown color
    }

    return 0;     // Success
}
```

We configure three pins as PWM outputs, and expose the `setColor` method as a [Cloud Function][particle-cloud-function], which will be accessible through the [Partical Cloud API][particle-cloud-api].

#### Testing Our Setup

If you assembled your circuit correctly, and successfully flashed your device with the firmware code, you should be able to make the following requests to change the color of your LED:

```bash
curl -X POST https://api.particle.io/v1/devices/$PARTICLE_DEVICE_ID/setcolor \
  -d access_token=$PARTICLE_TOKEN \
  -d arg=red

curl -X POST https://api.particle.io/v1/devices/$PARTICLE_DEVICE_ID/setcolor \
  -d access_token=$PARTICLE_TOKEN \
  -d arg=yellow

curl -X POST https://api.particle.io/v1/devices/$PARTICLE_DEVICE_ID/setcolor \
  -d access_token=$PARTICLE_TOKEN \
  -d arg=green

curl -X POST https://api.particle.io/v1/devices/$PARTICLE_DEVICE_ID/setcolor \
  -d access_token=$PARTICLE_TOKEN \
  -d arg=off
```

*NOTE:* You'll need to replace `$PARTICLE_DEVICE_ID` and `$PARTICLE_TOKEN` with your Device ID and Particle API Token (or better yet, `export` the values as environment variables).

## Meanwhile, in Travis CI...

With our Particle running the above code, creating a Travis CI integration becomes incredibly simple. All we need to do is make the same cURL requsts we did above at specific times during the build lifecycle.

The first thing we'll need to do is add our API Token and Device ID to the `.travis.yml` file. Since this is sensitive information, we're going to use Travis' `encrypt` function:

```bash
travis encrypt PARTICLE_DEVICE_ID="your_device_id" --add env.global
travis encrypt PARTICLE_TOKEN="your_token" --add env.global
```

If this worked, your `.travis.yml` file should now contain something that looks like the following (I've truncated the values for readability):

```yml
env:
  global:
  - secure: owjfRWVpTjNHmdijbyvOkk0AslnQ1hX3vNUvnsn5rQUa...
  - secure: g2Dqz+LIvGe2do6Z/hAnrQBAcJLS7w6eQli6Bn+wDc4V...
```

Next, we'll create a bash script to wrap up our cURL command:

```
#!/usr/bin/env bash

curl -X POST https://api.particle.io/v1/devices/$PARTICLE_DEVICE_ID/setcolor \
  -d access_token=$PARTICLE_TOKEN \
  -d arg=$1
```

And that's basically it - we can run this script anytime we want to change the color of our LED, and by calling this script throughout the build lifecycle we can easily indicate the current state (in-progress, success, failure) with our LED.

Here's how my build process looks like as defined in my `.travis.yml` file

```
before_install:
- "chmod +x ./travis-scripts/*.sh"
- "./travis-scripts/indicator/indicator.sh yellow"

script: "./travis-scripts/build.sh"

after_success: "./travis-scripts/indicator/indicator.sh green"
after_failure: "./travis-scripts/indicator/indicator.sh red"
```

The full source for this project, including the firmware, can be found on [GitHub][final-project].

Happy Hacking!

[meetup]: https://www.meetup.com/nodebotssf/
[slides]: /slides/nodebots-travis-ci
[travis]: https://travis-ci.org
[johnny-five]: http://johnny-five.io
[ifttt]: https://ifttt.com
[ngrok]: https://ngrok.com
[photon]: https://docs.particle.io/guide/getting-started/intro/photon/
[particle-cloud-function]: https://docs.particle.io/reference/firmware/photon/
[particle-cloud-api]: https://docs.particle.io/reference/api/
[final-project]: https://github.com/cat-haines/johnny-five-build-light/tree/photon/