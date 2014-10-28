---
layout:     post
title:      A Test Post
date:       2014-10-13 12:58:00
summary:    Installing and testing Jekyll
categories: jekyll pixyll
---

Hi there,

This is just a test to see if all this stuff works right.

### Installing Jekyll

Install ruby and gem

{% highlight bash %}
sudo apt-get install ruby ruby-dev gem
{% endhighlight %}

Install jekyll

{% highlight bash %}
sudo gem install jekyll
{% endhighlight %}

### Write a new post

I have not gotten the [Sublime Text 3 plugin](https://sublime.wbond.net/packages/Jekyll) for Jekyll to work yet. So I make a copy of the test posts, and edit the header.

Then I push to github to publish it online.

{% highlight bash %}
git commit -m "it's a blog post"
git push origin master
{% endhighlight %}