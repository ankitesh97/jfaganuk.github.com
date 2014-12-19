---
layout:     post
title:      Notes on SQLite
date:       2014-10-17 16:15:00
summary:    Some notes and usage of SQLite and RSQLite
categories: jekyll pixyll
---

I think SQLite a perfect database engine for projects that have a limited user scope. For instance, if you have an app on a phone, or you're managing data for some statistical analysis, or you're prototyping an app. It is not a good choice if you need lots of concurrency, two or more people need to write data to the database at once. SQLite is very fast if you use it properly

In Ubuntu you use SQLite3 to use the SQLite command line interface.

{% highlight bash %}
sudo apt-get install sqlite3
{% endhighlight %}

The package [R package for SQLite](http://cran.r-project.org/web/packages/RSQLite/index.html) frequently when I have a large set of complex data that I'm working with. However, I found that SQLite databases can frequently be easily corrupted. Here are some notes when using SQLite to get the best out of it.

##### Use indexes

I think the first problem you may encounter when trying to pull data out of a database with millions of rows is that it will feel slow. I have found that it sometimes is faster to [build an index](https://www.sqlite.org/lang_createindex.html) then run the search. Regardless, you should always be using indices on your tables.
{% highlight sql %}
create index if not exists indexname 
on tablename (columnname1, columnname2);
{% endhighlight %}

Although, if all you are doing is inserting data, and you have no interest in fetching data from a table. You could wait to build the index until you are done with your ingestion phase. Otherwise it updates the index every insert.

###### Create backups

A good way to make backups of the database is to use the .dump command and then restore it later. Make sure you aren't making any writes to the databse when this backup is being performed.

{% highlight bash %}
sqlite3 databasename.db .dump > databasename.bak
sqlite3 restoreddatabase < databasename.bak
{% endhighlight %}

###### Use Transactions

I'm actually not sure that data retrieval is benefitted from transactions at all (I don't know how they would). But data insertions certainly are. A transaction is a great way to prevent a database from being corrupted. As a practice now I do my inserts as a function. I open the database, begin a transaction, do a bulk insert, then commit, and disconnect from the database. I feel like this practice has led to far fewer corruptions.

I used to just keep a connection open during my entire analysis session. The connection string was at the top of my script files, and the disconnect at the bottom. This could be a problem if there is an error, or R crashes, etc. By using transactions and only opening a connection when you need it you are buffered from the inevitble crashing and errors.

{% highlight r %}

insertMyData <- function(d) {
	con <- dbConnect(SQLite(), 'dbname.db')
	dbBeginTransaction(con)
	dbGetPreparedQuery(con, 'insert into thetable (name, funstuff) values (:name, :funstuff)',
	                   bind.data = d)
	dbCommit(con)
	dbDisconnect(con)
}

{% endhighlight %}