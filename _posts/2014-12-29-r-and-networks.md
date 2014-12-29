---
layout: post
title: R and Networks
categories: []
tags: [R, SNA]
published: True
summary: The resources and tools available to you once you start is vast. Let’s get a lay of the land
date: 2014-12-29 11:02:55

---

## About R

R is a **programming language for statistical computing**. R is often viewed from two different perspectives. From the *statistician perspective* R is a powerful and flexible statistics package. From the *programmer perspective* R is a terrible computer language.

As a statistics package, I have had experience with many (SPSS, Stata, SAS, and R) and R suits me the best. Not to start a fight, but I sometimes wonder why people still teach these programs. But specifically for network analysis, none of these come close. Here at the LINKS Center we teach the use of UCINET as well. But again, R can do everything that UCINET can do and much more.

As a programming language, R is a disfigured beast. There are [some who think Python will take R over](http://readwrite.com/2013/11/25/python-displacing-r-as-the-programming-language-for-data-science), but R serves a very different need than Python. If you really want a programming language for scripting, or running a website, by all means use Python. But when you go down that route, you really should start considering the vast world of real programming languages like C/C++ and Java.

Hadley Wickham, a goliath of R-packages, believes that much of the time spent in data analysis is spent thinking about the program rather than actually running the analyses. And this is where R shines since it makes the thinking part much easier, while at some cost to the speed of the analysis. Although when I discuss high performance computing later, we will see that R is as fast or faster than other options available if that's the goal.

#### <i class="fa fa-bolt"></i> Getting started

First download and install [R from here](http://cran.rstudio.com/).

Next install Open Source Edition of [**R-Studio** from here](http://www.rstudio.com/products/RStudio/#Desk).

Then open RStudio.

#### <i class="fa fa-graduation-cap"></i> Learning R


If you are coming to R from another stats package, you may want to start with [Quick-R](http://www.statmethods.net/) which is set up with SPSS or Stata users in mind.

If you are coming to R as a programming language, you might want to just jump in to [Hadley Wickham's Advanced R Book](http://adv-r.had.co.nz/).


#### <i class="fa fa-question-circle"></i> Getting Help

Probably the most important thing to learn when getting into R is where and how to get help. One of the difficulties about R is that every single package has some different syntax. When we start looking at how to do analysis, there are very different ways of approaching problems and workflow in the ```igraph``` package than you would in the ```sna``` package.

##### Using the built-in help system

All functions have a built-in help, but some of these are more helpful than others. To see the help entry for any given function use the question mark command ```?```. For instance, if you want to get help on the ```sum``` function you type:

{% highlight R %}
# To get help on the "sum" command
?sum
?"sum"

# Or you can use the help command
help("sum")

# If you aren't sure what the full command is you can search with '??'
??sum
help.search("sum")

# You can even get help on the help function.
?"?"

# Or help on the "addition" function
?"+"
{% endhighlight %}

##### Using tab completion in RStudio

I use the tab completion a lot in RStudio because you tend to forget what 

![Sum tab completion]({{ site.url }}/assets/sum_tab_completion.gif)

##### StackOverflow

##### Going to the source

I mean two things when I say "going to the source" - I mean you can usually contact the package author directly, or if you are feeling daring you can start peeking into the source code of the package itself.



## Packages for Network Analysis

#### igraph

#### sna

#### statnet

#### siena

#### d3network

#### tnet

#### rgexf

#### igraphtosonia

#### 




