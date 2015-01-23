---
layout: post
title: Getting Network Data In and Out of R
categories: []
tags: [SNA, R, IntroToSNAinR]
published: True
date: 2015-01-02 18:08:41
summary: Another part of Intro the SNA in R. Imporing and exporting data, cleaning and preparing it.
---

In this part of *Introduction to Network Analysis in R* we will do some basic network analysis.

1. Survey different methods of importing / exporting data in R
2. Cleaning it up and preparing it for an igraph object

### Getting Network Data into R

There are a great many ways of importing data into R - I have not yet encountered a data format that I could not somehow import into R. That being said, some data formats are simpler to import than others.

Let's look at a few ways of getting data into R, but they are by no means the only ways.

1. [CSV](#comma-seperated-values-or-other-text-formats)
2. Excel
3. Database
4. Network analysis formats
5. Internet or web-scraping

##### Comma Seperated Values (or other text formats)

The CSV file is probably the easiest to work with. In my own work I use CSV files and databases. If I receive other formats I usually convert them to CSV or a database if I am going to work with them frequently.

For these examples I'm going to use a dataset that I first exported to CSV file from [UCINET 6](https://sites.google.com/site/ucinetsoftware/home). The dataset is called [*Campnet*](https://sites.google.com/site/ucinetsoftware/datasets/campdata) and comes from the second and third weeks of a three week workshop. Attendees were asked to rank order people the spent the most time with during the workshop. The *Camp92* file that I import shows the rank ordering. In this case a value of ```1``` indicates the strongest relationship and the highest values indicate the weakest relationships.

I created an exciting video showing how I exported the CSV file of the network data from UCINET here. The *campattr* file was exporte the same way.

<iframe width="420" height="315" src="//www.youtube.com/embed/XIMg17MHhhY" frameborder="0" allowfullscreen></iframe>

Here are the <i class="fa fa-download"></i>[Camp92.txt]({{ "/assets/Camp92.txt" | prepend: site.baseurl }}) file and the <i class="fa fa-download"></i>[campattr.txt]({{ "/assets/campattr.txt" | prepend: site.baseurl }}) files.

I almost always start with the option ```options(stringsAsFactors = F)```. If you don't use this option, or add the option to each ```read.csv``` statement, then text data will be read in as nominal factors. Nearly always, especially when dealing with network data, you want to keep that data as text and not as factors. There are many good reasons to use factors, but I like to control when and how I convert strings to factors.

{% highlight R %}
options(stringsAsFactors = F)
{% endhighlight %}

Next it is very easy to use the ```read.csv``` command to read in the data. You need to make sure the file path is specified properly.

{% highlight R %}
campattr <- read.csv("campattr.txt")
camp92 <- read.csv("Camp92.txt")
{% endhighlight %}

##### Excel

I almost always export Excel data to a CSV format. The Excel integration with R can sometimes be difficult to set up. If I were in a race with someone else to import an Excel file, I'm sure I would win nearly every time by exporting to a CSV and using ```read.csv``` than importing directly from the Excel file.

There are actually many packages capable of reading and writing to Excel files ([see a list here](http://cran.r-project.org/doc/manuals/r-patched/R-data.html#Reading-Excel-spreadsheets)). Installing the ```xlsx``` package can be a trial. If you use Linux, as I do, there is a [decent walkthrough here](http://tuxette.nathalievilla.org/?p=1380&lang=en).

I have an <i class="fa fa-download"></i>[XLSX file for testing here]({{ "/assets/campnet.xlsx" | prepend: site.baseurl }}). And this is exactly how I made it. After I imported and prepped the network data from CSV's.

The first line here creates a files *campnet.xlsx* with a sheet in it called *camp92*. The next line adds a new sheet to the *campnet.xlsx* file called *campattr* and filles it with the *campattr* data. Note the ```append=T``` flag. If you omit this then the second line with **overwrite** your data. You will have a file with only one worksheet called *campattr* and you won't have the *camp92* network data.

{% highlight R %}
library(xlsx)
write.xlsx(camp92, "campnet.xlsx", sheetName = "camp92", row.names = F)
write.xlsx(campattr, "campnet.xlsx", append = T, sheetName = "campattr", row.names = F)
{% endhighlight %}

Reading Excel data is pretty easy once you have the ```xlsx``` package up and running. Just point to the file, and say the sheet name or index.

{% highlight R %}
camp92 <- read.xlsx("campnet.xlsx", sheetName = "camp92")
campattr <- read.xlsx("campnet.xlsx", sheetName = "campattr")
{% endhighlight %}

##### Databases

The ```DBI``` package (**D**ata**b**ase **I**nterface) connect to many different kinds of databases. For complex projects with many different datasets, a database is my preferred way of managing data. Truly there is no better way.

And my favorite database engine for most analysis projects is currently SQLite. However, the DBI interface works equally well with other databases (MySQL, Postgres, and SQLServer). I will show two quickly examples with MySQL and SQLite.

SQLite doesn't save to some service that the OS runs, but rather it connects to a file that you an keep in a project folder. I also work from different computers using Dropbox, and MySQL won't sync with dropbox, but a SQLite file will. SQLite can also be lightning fast if you use indexes and lay everything out properly. My only real hold up with SQLite is that it does not allow concurrent modifcations to the data. This means you can do parallel processing that modifies the database.

{% highlight R %}
# Load the package
library(RSQLite)

# Connect to / create the database file
db <- "campnet.db"
con <- dbConnect(SQLite(), db)

# Write the data to the database.
dbWriteTable(con, "camp92", camp92)
dbWriteTable(con, "campattr", campattr)

# Read data from the database
camp92 <- dbGetQuery(con, 'select * from camp92')
campattr <- dbGetQuery(con, 'select * from campattr')

# Close the connection
dbDisconnect(con)
{% endhighlight %}

And here is an example using MySQL. Installing and maintaining a MySQL database is beyond the scope of this tutorial. Before you run the example below you have to first create a *campnet* database. I do not know how or if you can do it using the RMySQL package. You could do it through ```system``` calls, but I usually just do it at the command prompt. Note there is no space between ```-p``` and ```password```.

{% highlight bash %}
jfagan@computer:~$ mysql -u username -ppassword
create database campnet; -- at the MySQL prompt
{% endhighlight %}

Say you want to connect to your WordPress website, or a database you imported from a dump someone sent you. You can load the dump into a MySQL database and read from the database directly using R. This is a very simple example. 

{% highlight R %}
# Load the package
library(RMySQL)

# Connect to the database
con <- dbConnect(dbDriver("MySQL"), user = "root", password = "the_password", dbname = "campnet")

# Write some data
dbWriteTable(con, "camp92", camp92)
dbWriteTable(con, "campattr", campattr)

# Read the data back
camp92 <- dbGetQuery(con, "select * from camp92")
campattr <- dbGetQuery(con, 'select * from campattr')

# Disconnect
dbDisconnect(con)
{% endhighlight %}

##### Network Analysis Formats

It's almost silly that this is perhaps the **worst** way to get network data in or out of R. Sometime it is a good way to get data out of R and into a different program (like UCINET or Gephi). But if you plan on continuing to work in R here is the best way to save your networks:

{% highlight R %}
save(g, file="Campnet.rda")
load("Campnet.rda")
{% endhighlight %}

That script takes an igraph object ```g``` and saves it to an R data file called *Campnet.rda*. When you use the ```load``` command it will automatically load the data into an object named ```g```. This is important to know in case you already have an object named  ```g```. I will often put the object names in the file name, like *Campnet - g.rda* or something.

Let's look at a couple other formats. The ```igraph``` package claims several options for exporting network data. I say *claims* since many of the formats it purports to use do not work properly. Let's consider the very common Pajek format used by the [Pajek network analysis package](http://pajek.imfm.si/doku.php). In this example an igraph object with vertex attributes is saved in pajek format, but when the file is read back we can see those attributes are gone. Only the edge weight remains. However Pajek format should be able store vertex attributes.

{% highlight R %}

> # Let's see what this graph file looks like
> summary(g1)
IGRAPH DNW- 18 306 -- 
attr: name (v/c), gender (v/n), role (v/n), title (v/c), weight (e/n)
> # Write in the Pajek format
> write.graph(graph = g1, file = "campnet.paj", format = "pajek")
> # Is it the same network?
> read.graph("campnet.paj", format = "pajek")
IGRAPH D-W- 18 306 -- 
+ attr: weight (e/n)

{% endhighlight %}

The situation is better with [GML](http://en.wikipedia.org/wiki/Graph_Modelling_Language).

{% highlight R %}

> # Let's try gml
> write.graph(graph = g1, file = "campnet.gml", format = "gml")
> # Is it the same?
> read.graph("campnet.gml", format = "gml")
IGRAPH DNW- 18 306 -- 
+ attr: id (v/n), name (v/c), gender (v/n), role (v/n), title (v/c), weight (e/n)

{% endhighlight %}

I like to do visualization in [Gephi](http://gephi.github.io/). It is a very good platform for visualization and exploration. I have found the best way to get data from R into Gephi is using the GEXF format. For that I use the package ```rgexf```.

{% highlight R %}

{% endhighlight %}


##### Internet or Web-Scraping Data

Web-scraping ranges from incredibly simple one or two lines of code, to incredibly complex and elaborate. For now I'll show a simple example, but I'm thinking of dedicating an entire post to web-scraping a couple complex examples like Reddit complex threads, or the [FAO Food Trade network over time](http://faostat.fao.org/site/342/default.aspx).

### Cleaning and Preparing Network Data

Next I'm just doing some basic cleaning and prepping. The ```stri_trim``` function is from the ```stringi``` package. It removes spaces from the front and back of a string (that is instead of having a name read in as "  JOHN  " it is changed to "JOHN"). Next, I know this dataset has two time points. The first 18 rows are the first matrix and second 18 rows are the second matrix. So I added a time variable to the data.frame - a vector of 1's for time point one and 2's for time point two.

{% highlight R %}
library(stringi)
campattr$Node <- stri_trim(campattr$Node)
(camp92$time <- c(rep(1,18), rep(2, 18)))
 [1] 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2
{% endhighlight %}