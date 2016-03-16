#!/usr/bin/env bash
set -e # halt script on error

rm -rf _site

bundle exec jekyll build

cp CNAME _site/.
cd _site
git init

git config user.name "Travis CI"
git config user.email "haines2m@gmail.com"

echo "Deploying Changes"
git add -A . > /dev/null 2>&1
git commit -m "Deply to GitHub Pages" > /dev/null 2>&1

git push --force --quiet "https://${GH_TOKEN}@${GH_REF}" master:gh-pages > /dev/null 2>&1
echo "Success!!"
