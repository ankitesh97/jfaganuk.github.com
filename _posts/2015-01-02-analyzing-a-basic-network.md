---
layout: post
title: Getting Network Data In and Out of R
categories: []
tags: [SNA, R, IntroToSNAinR]
published: True
date: 2015-01-02 18:08:41
summary: Another part of Intro the SNA in R. Imporing and exporting data, cleaning and preparing it.
---

In this part of [*Introduction to Network Analysis in R*]({% post_url 2014-12-18-An-introduction-to-network-analysis-in-R %}) we will do some basic network analysis.

1. Survey different methods of importing / exporting data in R
2. Cleaning it up and preparing it for an igraph object

The final script for this section can be <i class="fa fa-download"></i>[found here]({{ "/assets/finalDataPrepExample.R" | prepend: site.baseurl }}). The data for this secion are found in these two files: <i class="fa fa-download"></i>[Camp92.txt]({{ "/assets/Camp92.txt" | prepend: site.baseurl }}) and <i class="fa fa-download"></i>[campattr.txt]({{ "/assets/campattr.txt" | prepend: site.baseurl }}).


### Getting Network Data into R

There are a great many ways of importing data into R - I have not yet encountered a data format that I could not somehow import into R. That being said, some data formats are simpler to import than others.

Let's look at a few ways of getting data into R, but they are by no means the only ways.

1. [CSV](#comma-seperated-values-or-other-text-formats)
2. [Excel](#excel)
3. [Databases](#databases)
4. [Network analysis formats](#network-analysis-formats)
5. [Internet or web-scraping](#internet-or-web-scraping-data)

Finally, I'll show how to [prepare and create the graph object](#cleaning-and-preparing-network-data).

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
library(rgexf)
g1.gexf <- igraph.to.gexf(g1)

# You have to create a file connection.
f <- file("campnet.gexf")
writeLines(g1.gexf$graph, con = f)
close(f)

g1.gexf.in <- read.gexf("campnet.gexf")
gexf.to.igraph(g1.gexf.in)
{% endhighlight %}


##### Internet or Web-Scraping Data

For now, here is the simplest web scraping you'll ever do. Just put the web address in place of the file location.

{% highlight R %}
x <- read.csv("http://jfaganuk.github.io/assets/Camp92.txt")
head(x)
{% endhighlight %}

You can use this to pull data from anywere from the web and get it in a raw form. Of course, if that raw form is already a CSV then you're in luck! 

Web-scraping ranges from incredibly simple one or two lines of code as shown, to incredibly complex and elaborate. I'm will dedicate an entire post to web-scraping a couple complex examples like Reddit complex threads, or the [FAO Food Trade network over time](http://faostat.fao.org/site/342/default.aspx). Or we can look at intermediate things like how to scrape html tables from Wikipedia, or how to use a web API.

### Cleaning and Preparing Network Data

In these next few steps we're going to maninulate the data we imported so that we can create a graph object.

#### Preparing the matrix data

Let's assume we're importing the CSV data.

{% highlight R %}
options(stringsAsFactors = F)
campattr <- read.csv("campattr.txt")
camp92 <- read.csv("Camp92.txt")
{% endhighlight %}

One thing you'll notice abpit the *campattr* data is that the *Node* column has spaces in it. 

{% highlight R %}
> campattr$Node
 [1] "  HOLLY" " BRAZEY" "  CAROL" "    PAM" "    PAT" " JENNIE" "PAULINE" "    ANN" "MICHAEL" "   BILL" "    LEE"
[12] "    DON" "   JOHN" "  HARRY" "   GERY" "  STEVE" "   BERT" "   RUSS"
{% endhighlight %}

I want to trim those spaces out to keep everything clean and consistent. I will use the ```stri_trim``` function from the ```stringi``` package. It removes spaces from the front and back of a string (that is instead of having a name read in as "  JOHN  " it is changed to "JOHN"). 

{% highlight R %}
library(stringi)
campattr$Node <- stri_trim(campattr$Node)
(camp92$time <- c(rep(1,18), rep(2, 18)))
 [1] 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2
{% endhighlight %}

Next, I know this dataset has two time points. The first 18 rows are the first matrix and second 18 rows are the second matrix. So I added a time variable to the data.frame - a vector of 1's for time point one and 2's for time point two.

{% highlight R %}
camp92$time <- c(rep(1,18), rep(2, 18))
{% endhighlight %}

Next let's actually build the graph object. Let's focus on time point one for now. First let's filter the data matrix so that we get only time point one. The phrase ```camp92$time == 1``` will return a vector of boolean (```TRUE``` and ```FALSE```) values and applies it to the rows. So we will only take rows where the time variable is equal to 1.

The seconed line removes the *Node* and *time* variables since we only need the network data for the next step. Again, this is another step that uses a boolean result. First it takes the column names of *camp92.time1*, asks which of those names are either **"Node"** or **"time"**, then it inverts it with the **!** operator. 

{% highlight R %}
camp92.time1 <- camp92[,camp92$time == 1]
camp92.time1 <- camp92.time1[,!(names(camp92.time1) %in% c('Node','time'))]
{% endhighlight %}

That example uses the base R functionality for filtering. I really like using either ```dplyr``` or ```data.table``` to do filtering like this. The ```dplyr``` way of doing things is soooo much easier to read and understand. It has two setps, filter where time equals 1, then deselect (notice the - sign) where the columns match **"Node"** or **"time"**.

{% highlight R %}
library(dplyr)
camp92.time1 <- filter(camp92, time == 1) %>% select(-matches('Node|time'))
library(data.table)
camp92 <- data.table(camp92)
camp92[time == 1, setdiff(names(camp92), c('Node','time')), with=F]
{% endhighlight %}

Finally, we are going to create an ```igraph``` object from the data. The ```igraph``` functions expect a raw matrix of numbers - not a data.frame. So we coerce it to a matrix first. There are many ways of creating an ```igraph``` object, in this case we have an **adjacency matrix** as our data, so we use ```graph.adjacency``` to create the object. It's a weighted and directed network as well, so make sure to toggle those flags.

#### Creating the Graph Object

{% highlight R %}
library(igraph)
camp92.time1 <- as.matrix(camp92.time1)
g1 <- graph.adjacency(camp92.time1, weighted = T, mode = 'directed')
{% endhighlight %}

Now we have our graph object. A summary shows that we have 18 nodes and 306 edges. There are two attributes, name and weight. The name (v/c) means that name is a **v**ertex attribute and is a **c**haracter data type. And weight (e/n) means weight is an **e**dge attribute and is a **n**umeric data type.

{% highlight R %}
> summary(g1)
IGRAPH DNW- 18 306 -- 
attr: name (v/c), weight (e/n)
{% endhighlight %}

But we have some attributes from the *campattr* file to import to the vertices as well. They have data on gender and role. To import them first I want to make sure I have the correct indices for assigning them to the vertices. If the network data and the attribute data are in the correct order (such as they are here) it really isn't a problem. But sometimes there are vertex data in the attributes for vertices that aren't in the network (or vice versa). Therefore it's important to follow this matching step. 

>Note: it is very important the names are *exactly the same in both data sets*. The spaces are automatically trimmed from the vertex names when we created the adjacency matrix from the data. Which is why we had to trim the spaces from the *campattr$Node* values as well.

The *V* function accesses the vertices of the network. Then, like a data frame, we can assign a new attribute using the *$* operator. Or you can use the ```set.vertex.attribute``` function if you like.

{% highlight R %}
ix <- match(V(g1)$name, campattr$Node)

# Using the V function and $ operator
V(g1)$gender <- campattr$Gender[ix]
V(g1)$role <- campattr$Role[ix]

# Using set.vertex.attribute
set.vertex.attribute(graph = g1, name = 'gender', value = campattr$Gender[ix])
set.vertex.attribute(graph = g1, name = 'role', value = campattr$Role[ix])
{% endhighlight %}

Just a nit-picky thing, but I don't like the names in all capital letters. When we do the visualizations and tables it looks like it should be rendered on a dot-matrix printer. So I want to change the names to Title Case (JOHN becomes John).

{% highlight R %}
V(g1)$title <- stri_trans_totitle(V(g1)$name)
{% endhighlight %}

#### Using ```graph.data.frame``` instead

A relatively new function was introduced to **igraph** which takes a ```data.frame``` and creates a graph from the data frame. It also simultaneously imports the vertex attributes or edge attributes as well. But in order to use it we have to reshape the adjacency matrix into an edge list. 

To conver the adjacency matrix into an edge list, I use the **reshape2** package with the ```melt``` function. It takes a "wide" data frame and converts it into a "tall" data frame.

{% highlight R %}
library(reshape2)
camp92.el <- melt(camp92, id.vars = c('Node','time'))
{% endhighlight %}

And here is a comparison.

{% highlight R %}
> head(camp92)
     Node HOLLY BRAZEY CAROL PAM PAT JENNIE PAULINE ANN MICHAEL BILL LEE DON JOHN HARRY GERY STEVE BERT RUSS time
1   HOLLY     0      2    15   8   4     12      10   5       3   11  13   1   16     9   17     7    6   14    1
2  BRAZEY     1      0    12   2  10     11       5   7       9   17   3   8   15    13   16     6    4   14    1
3   CAROL    17     15     0   1   2      4       6  12       7   16  11  10    3     5   13     8    9   14    1
4     PAM     9      5     6   0   3      4       1   2       8   15  16  13    7    12   17    11   10   14    1
5     PAT     4     10     8   3   0      1       2  14       9   16   7  13   11    12   17     5    6   15    1
6  JENNIE    11      9     4   2   1      0       7   3      15   16  10  14   12    13   17     5    6    8    1
> head(camp92.el)
     Node time variable value
1   HOLLY    1    HOLLY     0
2  BRAZEY    1    HOLLY     1
3   CAROL    1    HOLLY    17
4     PAM    1    HOLLY     9
5     PAT    1    HOLLY     4
6  JENNIE    1    HOLLY    11
{% endhighlight %}

Now we have an edge list. The new data set ```camp92.el``` has three columns listing each edge in the network. The second row for instance shows that there is an edge from BRAZEY to HOLLY with a value (weight) of 1.

Next we need to rename and reorder the columns. The function ```get.data.frame``` expects the first two columns to be a "source" and "target" (that is each edge is listed as directed where the first column has all the source nodes and the second column has all the target nodes).

{% highlight R %}
# reorder the columns
camp92.el <- camp92.el[,c('Node','variable','value','time')]
# rename the columns
colnames(camp92.el) <- c('source','target','weight','time')
# we also need to trim the names
camp92.el$source <- stri_trim(camp92.el$source)
camp92.el$target <- stri_trim(camp92.el$target)
{% endhighlight %}

And when everything is set up correctly we create the graph:

{% highlight R %}
g <- graph.data.frame(camp92.el, directed = T, vertices = campattr)
{% endhighlight %}

And here are the two approached compared completely:

{% highlight R %}
camp92.el <- melt(camp92, id.vars = c('Node', 'time'))
camp92.el <- camp92.el[,c('Node','variable','value','time')]
colnames(camp92.el) <- c('source','target','weight','time')
camp92.el$source <- stri_trim(camp92.el$source)
camp92.el$target <- stri_trim(camp92.el$target)
g <- graph.data.frame(camp92.el, directed = T, vertices = campattr)

camp92.time1 <- filter(camp92, time == 1) %>% select(-matches('Node|time'))
camp92.time1 <- as.matrix(camp92.time1)
rownames(camp92.time1) <- colnames(camp92.time1)
g1 <- graph.adjacency(camp92.time1, weighted = T, mode = 'directed')
ix <- match(V(g1)$name, campattr$Node)
V(g1)$gender <- campattr$Gender[ix]
V(g1)$role <- campattr$Role[ix]
{% endhighlight %}

However, the ```g``` object from ```graph.data.frame``` has edges from both time points, so it has to be filtered before analysis. Also the attrbute names aren't the same in both ```g``` and ```g1```. But I just wanted to show another way of producing the graph object.

#### Simplify

The last step is a sort of cleaning step. The problem is that because of the way we imported the data there are self-loops with a weight of 0. These are the 0's along the diagonal of the matrix. Having a weight of zero causes problems. We can either filter out any edges with a weight of 0 or we can use the simplify function as done here:

{% highlight R %}
g <- simplify(g, remove.loops = T, remove.multiple = F)
{% endhighlight %}

We want to remove loops, since people should not be rating themselves, but we need to retain multiple edges since we have two time points in our graph. An edge for each time point. And now I think we have a useable graph file.

### Time to Analyze: [A Simple Network Analysis]({% post_url 2015-01-24-basic-network-analysis %})

Now that we have a graph object. Let's analyze it. That's the next chapter.

