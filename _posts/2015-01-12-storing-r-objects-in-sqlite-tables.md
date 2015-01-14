---
layout: post
title: Storing R Objects in SQL Tables
categories: []
tags: [R, SQLite]
published: True
date: 2015-01-12 12:55:04
summary: Keep your analyses and prepared rdata objects indexed in a database.

---

I am running network simulations. But at this time I'm not certain what sorts of analyses should be run on the resulting networks. So I want to store the network objects for later anlysis. I could store each of the networks as ```.rda``` files with the *save* command, but I feel like that would result in a folder full of thousands, or even millions of files. That's unseamly. 

It's not even about speed for me, it's about cleanly managing the data. Plus I can store different attributes and information about the simulations (the size, the time it took, different parameters for its creation, etc). Then I can search and recall the results according to different parameters. It would be perfect.

Let's say this is the object I want to store. It's a list that contains graph objects resulting from a [Watts-Strogatz model](http://en.wikipedia.org/wiki/Watts_and_Strogatz_model). I could vary the different parameters, but this is just a proof of concept for now. I want to store each graph as an entry in a SQLite table 

{% highlight R %}
gs <- list()
for(i in 1:10)
  gs[[i]] <- watts.strogatz.game(1, 100, 5, 0.05)
{% endhighlight %}

#### Blobs

So SQLite is the database of choice here. It stores as a single file that I can keep in a Dropbox folder. I like that. And SQLite has a [datatype called a *BLOB*](https://www.sqlite.org/datatype3.html) which stores a blob of byte data exact how it was input.

Here I create the table in the database. I only have an *_id* variable for indexing, but I could add other columns that refer to the size of the netork, or the different parameters of the WS model.

{% highlight R %}
dbGetQuery(con, 'create table if not exists graphs 
                 (_id integer primary key autoincrement, 
                  graph blob)')
{% endhighlight %}

#### Serialize

I referred to the [unit tests for RSQLite](https://github.com/josephw/RSQLite/blob/master/inst/UnitTests/blob_test.R) to see how to do a blob insert. We need the R-object condensed into a single item we can insert into a database. There are apparently many ways to accomplish this. One way is [*dump*](http://stat.ethz.ch/R-manual/R-devel/library/base/html/dump.html) which outputs  the structure of an R object. It usually dumps to a file that can be *sourced*, but I believe you can export it to a character string. I attempt to export it to a character string, without luck. It also spawned warnings about inadequate *deparse* or something.

But then I learned of [*serialize*](http://stat.ethz.ch/R-manual/R-devel/library/base/html/serialize.html) which will do exactly what I want: convert an R object to a vector of raw bytes. This line here converts the list into a data.frame with a column in which each row is a raw vector of the graph object. Then the *I* function forces the data.frame to store the whole vector as an entry in the data.frame.

{% highlight R %}
df <- data.frame(g = I(lapply(gs, function(x) { serialize(x, NULL)})))

# And insert it
dbGetPreparedQuery(con, 'insert into graphs (graph) values (:g)', bind.data=df)
{% endhighlight %}

#### Retrieve the result

Now we can select the data out of the database and unserialize it. It's pretty simple.

{% highlight R %}
df2 <- dbGetQuery(con, "select * from graphs")
gs2 <- lapply(df2$graph, 'unserialize')
{% endhighlight %}

And now the compulsory network image:

{% highlight R %}
g <- gs2[[1]]
V(g)$size <- log(betweenness(g)) + 1
V(g)$color <- "#66c2a4"
V(g)$frame.color <- "#238b45"
plot(g, vertex.label = NA)
{% endhighlight %}

![Sqlite blob test.]({{ "/assets/sqlite_blob.png" | prepend: site.baseurl }})

#### The Full Code

<script src="https://gist.github.com/jfaganUK/5a6ae4c2be54e45973f1.js"></script>