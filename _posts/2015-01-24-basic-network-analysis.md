---
layout: post
title: A Simple Network Analysis
categories: []
tags: [SNA, R, IntroToSNAinR]
published: True
date: 2015-01-24 21:41:46
summary: Introduction to SNA in R&#58; A simple network analysis

---

In this section of [Introduction to Network Analysis in R]({% post_url 2014-12-18-An-introduction-to-network-analysis-in-R %})I assume that we have imported and have a basic graph object. Now we want to explore the network and see what we have.

### Filtering the network

I start with the assumption that have the network ```g``` which has edges for both time-points present in the graph object.

1. Only keep edges with a weight less than four. (this network uses ranking for weight meaning 1, 2, 3 are the three strongest weights, larger numbers are weaker)
2. Create two networks at each time point

{% highlight R %}
# filter the network for only the top three picks
g.edge3 <- subgraph.edges(g, which(E(g)$weight < 4))

# time 1 and 2
g1.edge3 <- subgraph.edges(g.edge3, which(E(g.edge3)$time == 1))
g2.edge3 <- subgraph.edges(g.edge3, which(E(g.edge3)$time == 2))
{% endhighlight %}

We can actually put both the time points into a single object so we can easily loop over all the time points when doing analysis.

{% highlight R %}
# stack both time points into a list
gs <- list()
gs[[1]] <- g1.edge3
gs[[2]] <- g2.edge3
{% endhighlight %}

### Centrality Measures




#### Betweenness

#### Degree

### Clusters an Cohesion

### Extracting Results for Other Purposes

### Visualization Results

