---
layout: post
title: An Introduction to Network Analysis in R
date: 2014-12-18 23:21:36
categories: []
tags: [SNA, R, IntroToSNAinR]
published: True
summary: Table of contents for my Introduction to Network Analysis in R series.

---

I am writing a series of posts that will provide a broad introduction to the network analysi capabilities of R. I will use this set of posts as the basis for the different lessons I have for R, both at the LINKS Workshop here at the [LINKS Center for Social Network Analysis](https://sites.google.com/site/uklinkscenter/home) and elsewhere. I like to use the ```igraph``` package primarily for my analysis, but I plan on covering bits and pieces of the dozens of other packages out there. Although this work is not intended to be an introduction to network theory and it is assumed you have some familiarity with network theory.

# Contents

### [R and Networks]({% post_url 2014-12-29-r-and-networks %})
The resources and tools available to you once you start is vast. Let's get a lay of the land.

  * A very brief introduction to R.
  * A list and discussion of network analysis packages in R.
  * The network analysis workflow, from data to results. 
  * How R can integrate with other software.

### [Getting Network Data into R]({% post_url 2015-01-02-analyzing-a-basic-network %})
Importing network data.

  * Importing data from various sources.
  * Cleaning and preparing the network data
  * Creating the graph object

### [A Simple Network Analysis]({% post_url 2015-01-24-basic-network-analysis %})
After the data is ready, let's analyze it.

  * Centrality measures
  * Clusters and cohesion
  * Extracting results for use in modeling
  * Visualizng analysis

### Manipulating the Network
What if you need to change the network data before or after analyzing it?

  * Subnetworks and trimming
  * Two-mode projections
  * Inserting and deleting

### Visualizing the Network
Insights can often come from staring at the results. Basic visualization using ```igraph```.

  * Layouts
  * The plotting options
  * Cleaning up some of the spaghetti

### Modeling Networks and Hypothesis Testing
A very important and growing area in network analysis today is in exponential random graph models (ERGM) and longitudinal modeling with Sienna.

  * Using QAP
  * A basic ERGM example
  * A basic Sienna example

### Dealing with Difficult Data
The data you have is rarely in the format you really need it to be in. This section will discuss taking dirty data and transforming into something we can use for network analysis.

  * Data munging survey data
  * Working with archival data

### Dealing with Large Networks
Large networks are becoming more common as big data sources become accessible. For some strange reason R has a reputation for being slow. It's probably because you don't know how to use it right.

  * Using the right function for the right job
  * Parallel computing of analyses
  * RCPP and compiling intensive operations

### Shareable Interactive Graphics
The world is a big place. In this section I will discuss some of the packages that are available for publishing and sharing results to the web. These results could be static or interactive.

  * Using Shiny
  * Using d3Network
  * Other ways of sharing



