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

As a statistics package, I have had experience with many (SPSS, Stata, SAS, and R) and R suits me the best. Not to start a fight, but I sometimes wonder why people still teach these programs. Specifically for network analysis, none of these come close. Here at the LINKS Center we teach the use of UCINET as well. But again, R can do everything that UCINET can do and much more. 

As a programming language, R has faults. However [R has been increasing tremendously in popularity](http://www.tiobe.com/index.php/content/paperinfo/tpci/index.html) even compared to programming languages (not just statistics pakages).

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

I use the tab completion a lot in RStudio because you tend to forget what the different options are. To use tab completion in RStudio, put your cursor inside some function text and hit *TAB*. Then you can use the arrow keys to select the options you want.

![Sum tab completion]({{ site.url }}/assets/rstudio-tabs.gif)

This method also works if you have data frame or list object to select a column, or use it to help you auto-complete the names of variables or function names. Especially nice if the names are long.

##### Reach Out to the Community

The question/answer site [StackOverflow has a great community](http://stackoverflow.com/questions/tagged/r) dedicated to answering questions you might have about R. There are even hundreds of questions specifically tagged just for [R with the ```igraph``` package](http://stackoverflow.com/questions/tagged/r+igraph).

For example, [```igraph``` has a fantastic introduction and help page](http://igraph.org/r/) just for the R-version of the software (```igraph``` is a C-package primarily that is also ported to ```python```). There is also an [```igraph``` mailing list](http://lists.nongnu.org/archive/html/igraph-help/) that you can search or post questions to. Many packages now [host their code on GitHub](https://github.com/igraph/igraph), which is a great place to submit issues, bugs, or suggestions.

##### Going to the source

I mean two things when I say "going to the source" - I mean you can usually contact the package author directly, or if you are feeling daring you can start peeking into the source code of the package itself.

## Packages for Network Analysis

There are dozens of packages for network analysis, and the number grows every year. But I personally only use a few of them frequently. The packages you most frequently would see me use are ```igraph``` for all sorts of analysis and graph handeling, ```regexf``` for exporting graph files to Gephi, and sometimes ```sna``` for functions that ```igraph``` is missing (like QAP correlation).


#### General Networks: ```igraph``` and ```sna```

Generally if you use R to do social network analysis you are going to use one of these two packages. There are benefits to using either of them. But I tend to use ```igraph``` for two big reasons.
  
  1. *```igraph``` is much faster*. See a [short benchmark I did to demonstrate]({{ site.url }}/assets/sna_igraph_benchmark.html) that **betweenness** and **shortest paths** are calculated about 5-7x faster. The ```igraph``` package is coded in the back end entirely in C, which makes it blazingly fast. It is always preferable to use ```igraph``` functions instead of writing your own as much as possible since you will experience a large speed difference.
  2. *The ```igraph``` objects are compact and consistent.* The graph objects for ```igraph``` can hold vertex attributes, visual display attributes, edge attributes, and when you filter or change the graph the attributes are preserved. Every function expects an igraph object and it doesn't matter how you initially formatted the data. The ```sna``` package tends to use raw matrices, or is generally more complicated (you can use the ```network``` package to add on proper handling of network objects for instance). I usually have a harder time keeping the different elements of my analysis together when using ```sna```.

That being said, the ```sna``` package is written more for *social* network analysis and we written by social scientists while the ```igraph``` package was written by computer scientists (probably why the code is so much better) and is oriented to problems that computer scientists tend to face. The ```igraph``` package has lots of functions for community structure and random graph generating models.  There are functions in the ```sna``` package that the social scientist would expect. For instance the ```sna``` package has a *QAP correlation* function, and it plays better with ```ergm```. The ```sna``` package supports an ecology of different packages, including network, ergm, statnet, tergm, networkDynamic, ndtv, etc. However, it's very easy (one line of code normally) to convert an ```igraph``` object into something we can use for QAP, ERGM, or Siena.


> <i class="fa fa-exclamation-triangle fa-2x red"></i> If you load both ```igraph``` and ```sna``` you will have conflicted function names. For instance, both packages have a ```betweenness``` function for that centrality measure. To make sure you are using the correct function you need to use the namespace, or double colon operator (i.e. ```igraph::betweenness()``` vs. ```sna::betweenness()```)

#### Statistical Modeling: ```statnet```, ```ergm```, ```siena```, & ```relevent```

As a networks researcher you may want to test certain hypotheses such as, are men more likely to connect with other men than women?, do the characteristics of a node determine it's position?, or does the structure of one network predict the structure of a different network? These questions are difficult or impossible to answer with standard statistical techniques largely do the violation of independence assumptions. To account for this researchers use a class of models known as [*p\** models or *exponential random graph models* (ERGM)](http://ptrckprry.com/course/ssd/Robi07a.pdf).

There are longitudinal approaches to network modeling as well. What factors impact the development of network structure? You can explore these kinds of questions with [Siena models](http://www.stats.ox.ac.uk/~snijders/siena/siena_r.htm) using ```rsiena``` models, or [Relational Event Models](http://orm.sagepub.com/content/17/1/23.abstract) ```relevent```.

#### Visualization: ```igraphtosonia```, ```ndtv```, ```rgexf```, & ```d3network```

These are packages for exporting to other visualization software, making interactive visualizations, or making animations of dynamic networks. [SoNIA](http://web.stanford.edu/group/sonia/) is software for animating dynamic networks, and ```igraphtosonia``` will take a dynamic igraph graph object and export it to a format that SoNIA can use. The ```ndtv``` package is an excellent package for the analysis and visualization of dynamic networks and interacts with ERGM models in R.

You can create some very nice images in R, but [Gephi](http://gephi.github.io/) is a fantastic platform for network visualization and exploration and ```rgexf``` will export file that Gephi can use. The GEXF format is can also be used by [SigmaJS](http://sigmajs.org/), which is an embedded web-visualization library. Another option for web-visualization or dynamically interacting with your network data, use the ```d3network``` package which uses the [D3js](http://d3js.org/) library to create interactivity.

#### Other: ```tnet```, ```pii```, ```egonet```

Other packages that you might use for specialized purposes. For instance ```tnet``` has an implementation of a two-mode clustering coeficient. The ```egonet``` package has special functions for ego-network analysis. A package I'm authoring, ```pii```, has an implementation of the *political independence index*.

#### Tips for Searching for Packages

If you want to see if a function has been implemented already for a problem you have, start with Google and append *r*, *cran*, or *rstats* to the front of your query. Search for "cran two mode clustering" or check out [RSeek.org](http://www.rseek.org/) which is a specialized search engine for R questions.

#### Next: [Getting Data in and Out of R]({% post_url 2015-01-02-analyzing-a-basic-network %})

Next we'll import some network data, clean and prepare it, do some basic analyses, do some basic visualization, and export the data and results.



