---
title: Instructions for documentation
layout: doc
---

# Documentation for torch-cephes

## How to generate the doc
Generate using [bundler](http://bundler.io/#getting-started) and [Jekyll](http://jekyllrb.com/docs/installation/):
{%highlight bash}
cd doc/src
bundle exec jekyll build --source ./ --destination ../html
{%endhighlight}

Commit
{%highlight bash}
git commit -m "Update HTML doc"
{%endhighlight}

Then merge to the gh-pages branch:
{%highlight bash}
cd ../..
git checkout gh-pages
git merge master -X subtree=doc/html
{%endhighlight}

And push:
{%highlight bash}
git push
git checkout master
{%endhighlight}
