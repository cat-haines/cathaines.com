---
layout: post
title:  Building Pebble Apps with Travis CI
date:   2016-02-28 11:22
description:
 Automatically build your Pebble app when you make a commit, and track it's build status in your project's README.
categories:
- code
- pebble
- travis
---

I've been spending a fair bit of time tinkering with [Travis CI][travis-ci] lately, and it's probably pretty safe to say that it's one of my favourite  tools at the moment. Travis CI, for those unfamiliar with it, is a [continuous integration][wikipedia-ci] tool, it enables developers to easily build, test, and deploy their projects on an ongoing basis.

In this post, we're going to look at how to setup Travis CI to build a Pebble application.

<!-- more -->

## tl;dr

If you're looking to get up and running as quickly as possible, you can follow these simple steps:

- Fork the [pebble-travis][pebble-travis] project.
- Create a [Travis CI][travis-ci] account if you don't already have one.
- Find the repository you just forked on your Travis CI [profile page][travis-profile].
- Toggle the build switch for the repository.

*And that's really all that's required. Whenever you push a change to the cloned repository, it will kick off a new Travis CI build!!*

The rest of this blog post will look at how the actually integration works, and hopefully provide enough information to enable to you modify and extend the project to suite you specific needs.

## Before We Get Started

In order to follow along with this blog post, you're going to need a few things:

- A [GitHub][github] account
- A [Travis CI][travis-ci] account
- A Pebble project hosted on GitHub

We will also need to enable the Travis integration for the GitHub repo we want to build. Don't worry - Travis and GitHub have a tight integration, and this step is almost non-existent: head over to your [profile page][travis-profile] and "Flick the repository switch on."

## .travis.yml

The next step is to create a `.travis.yml` file, which specifies what Travis CI will do when we push to GitHub. Here's what our base file is going to look like:

```yml
sudo: false

language: python
python:
 - 2.7
```

We've specified `sudo: false`, which tells Travis CI to build our project in a [container-based][travis-environments] (Linux) environment. Using a container-based environment ensures that our builds will spin up as quickly as possible after a commit has been pushed, but we won't be allowed to use `sudo` in any of our scripts..

We've also specified `language: python`. This may seem a bit odd at first glance, but since the Pebble Tool is written in Python, this will make installing the tool (and its dependencies) a *lot* simpler!

## The Build Lifecycle

*So what actually happens when a build is triggered in Travis CI?*

The first thing Travis does is look at the `.travis.yml` file to determine what environment and language the developer has selected. The combination of the environment and language determines what set of tools and resources come pre-installed in our build environment.

Once the base environment has been setup, the [build lifecycle][travis-build] begins. Each step in the build lifecycle has a default command that can be overridden by specifying new behaviour in our config file. We're going to add the following to the end of our `.travis.yml` file:

```yml
before_install:
 - echo before_install
install:
 - echo install

before_script:
 - echo before_script
script:
 - echo script
```

If we commit and push these changes, the resulting build should pass and include the following logs:

```
$ python --version
Python 2.7.9
$ pip --version
pip 6.0.7 from /home/travis/virtualenv/python2.7.9/lib/python2.7/site-packages (python 2.7)
$ echo before_install
$ echo install
$ echo before_script
$ echo script
```

Now that we understand the basics of the build lifecycle, and the order in which scripts execute, we can prepare our project for a slightly more complex example. We're going to create some custom bash scripts to be executed during the `install` and `script` steps, and use the `before_install` and `before_script` steps to grant them execute privileges:

```yml
# Grant the install script execute privileges
before_install:
 - chmod +x ./scripts/ciinstall

# Run a script to install our build chain
install:
 - ./scripts/ciinstall

# Grant the build script execute privileges
before_script:
 - chmod +x ./scripts/cibuild

 # Run a script to build and test our project
script:
 - ./scripts/cibuild
```

The last thing we need to do to get this new build to work, is create `/scripts/ciinstall` and `/scripts/cibuild`. Here's what they're going to look like:

```bash
#!/usr/bin/env bash
# {project_root}/scripts/ciinstall
set -e # halt script on error

echo Hello Install Step
```

```bash
#!/usr/bin/env bash
# {project_root}/scripts/cibuild
set -e # halt script on error

echo Hello Script Step
```

Adding these new files (along with the changes to our `.travis.yml`), and pushing them to GitHub should result in a successful build:

```
$ python --version
Python 2.7.9
$ pip --version
pip 6.0.7 from /home/travis/virtualenv/python2.7.9/lib/python2.7/site-packages (python 2.7)
before_install
$ chmod +x ./scripts/ciinstall
$ ./scripts/ciinstall
$ chmod +x ./scripts/cibuild
$ ./scripts/cibuild

The command "./scripts/cibuild" exited with 0.
Done. Your build exited with 0.
```

## Installing the Pebble Tool

We're in great shape at this point. We could take our `.travis.yml` file along with our `/scripts` folder and use it as a starting point for just any project we want to build in Travis (we could just need to change the `language` if we were working with something other than Python).

Let's take a look at how we can extend our current Travis setup to install the Pebble Tool, and build our project!

### Download and install the Pebble Tool

First things first - we need to download and install the latest version of the Pebble Tool. To do this, we'll add the following to the bottom of our `ciinstall` script:

```bash
mkdir pebble-dev
cd pebble-dev
curl -O https://s3.amazonaws.com/assets.getpebble.com/pebble-tool/pebble-sdk-4.2-linux64.tar.bz2
tar -jxf pebble-sdk-4.2-linux64.tar.bz2
```

That was easy, but there's one problem - we'll need to update our `ciinstall` script every time there's an update to the Pebble Tool. We want to avoid modifying our install script once it's working, so we're going to define what version of the Pebble Tool it should fetch through an [environmental variable][travis-variables]. We can set the environmental variable by adding the following to the bottom of our `.travis.yml` file:

```yml
env:
  global:
    - PEBBLE_TOOL=4.2
```

This allows us to rewrite our `ciinstall` with $PEBBLE_TOOL in place of "4.2":

```bash
mkdir pebble-dev
cd pebble-dev
curl -O https://s3.amazonaws.com/assets.getpebble.com/pebble-tool/pebble-sdk-$PEBBLE_TOOL-linux64.tar.bz2
tar -jxf pebble-sdk-$PEBBLE_TOOL-linux64.tar.bz2
```

### Download and Install Python Libraries

The next step in the install guide tells us to install Python 2.7, and pip. We're able to skip this step since Python 2.7 and pip will come pre-installed in our Travis CI environment. We do however, still need to perform the `virtualenv` step, so we'll add the following to the bottom of `ciinstall`:

```bash
cd pebble-sdk-$PEBBLE_TOOL-linux64
virtualenv --no-site-packages .env
source .env/bin/activate
pip install -r requirements.txt
deactivate
```

### Install Pebble Emulator Dependencies

Finally, we need to install the emulator's dependencies with `apt-get`. The guide tells us to run `sudo apt-get install libsdl1.2debian libfdt1 libpixman-1-0`, which we can't do, as we're not allowed to use `sudo`.

Instead, we're going to specify the packages in our configuration file and let Travis take care of installing them for us. We can do this by adding the following to the bottom of our `.travis.yml` file:

```yml
addons:
  apt:
    sources:
      - libsdl1.2debian
      - libfdt1
      - libpixman-1-0
```


## Building a Pebble App

Now that our build environment has the latest version of the Pebble Tool installed, building out project is as simple as adding the following line to our `cibuild` script:

```
# Pipe 'yes' into pebble tool to accept terms and conditions
yes | ./pebble-dev/pebble-sdk-$PEBBLE_TOOL-linux64/bin/pebble build
```

This command will build your Pebble project (and automagically answer 'yes' when the Pebble Tool asks whether you accept the terms and conditions). Assuming we've done everything correctly, we should get a passing build and the following logs (which I've tidied up so you don't need to scroll as far):

```
$ chmod +x ./scripts/cibuild
$ ./scripts/cibuild
Pebble collects metrics on your usage of our developer tools.
We use this information to help prioritise further development of our tooling.

If you cannot respond interactively, create a file called ENABLE_ANALYTICS or
NO_TRACKING in '/home/travis/.pebble-sdk/'.

Would you like to opt in to this collection? [y/n] No SDK installed; installing the latest one...
To use the Pebble SDK, you must agree to the following:

PEBBLE TERMS OF USE
https://developer.getpebble.com/legal/terms-of-use

PEBBLE DEVELOPER LICENSE
https://developer.getpebble.com/legal/sdk-license

Do you accept the Pebble Terms of Use and the Pebble Developer License? (y/n) Downloading...
100%[======================================================]   3.78 MB/s Done.

...

-------------------------------------------------------
APLITE APP MEMORY USAGE
Total size of resources:        4092 bytes / 125KB
Total footprint in RAM:         855 bytes / 24KB
Free RAM available (heap):      23721 bytes
-------------------------------------------------------
-------------------------------------------------------
CHALK APP MEMORY USAGE
Total size of resources:        4092 bytes / 256KB
Total footprint in RAM:         855 bytes / 64KB
Free RAM available (heap):      64681 bytes
-------------------------------------------------------
-------------------------------------------------------
BASALT APP MEMORY USAGE
Total size of resources:        4092 bytes / 256KB
Total footprint in RAM:         855 bytes / 64KB
Free RAM available (heap):      64681 bytes
-------------------------------------------------------

...

'build' finished successfully (0.427s)


The command "./scripts/cibuild" exited with 0.

Done. Your build exited with 0.
```

## What's Next

This is intended to be the first step towards a continuous **delivery** solution for Pebble apps - but the next step, automatically publishing a new release to the appstore, is a bit tricky at the moment.. But don't worry, we'll come back to that in a future post!

[travis-ci]: https://travis-ci.org
[wikipedia-ci]: https://en.wikipedia.org/wiki/Continuous_integration
[pebble-travis]: https://github.com/cat-haines/pebble-travis
[cat-haines]: https://travis-ci.org/cat-haines/cathaines.com
[github]: https://github.com
[pebble-tool]: https://developer.pebble.com/sdk
[travis-profile]: https://travis-ci.org/profile/
[travis-environments]: https://docs.travis-ci.com/user/ci-environment/#Virtualization-environments
[travis-build]: https://docs.travis-ci.com/user/customizing-the-build/#The-Build-Lifecycle
[pebble-install]: https://developer.pebble.com/sdk/install/linux/
[travis-variables]: https://docs.travis-ci.com/user/environment-variables/
[travis-sticker]: https://docs.travis-ci.com/user/status-images/
