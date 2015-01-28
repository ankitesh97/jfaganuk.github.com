### Create the campnet graph object
# The dataset was exported from UCINET

# Clear the workspace and do a gabarbage collection
rm(list=ls())
gc()

# dplyr package for filtering and transforming data
# igraph for network operations
# stringi to clean up and change the strings
# reshape2 to create an edgelist from the matrix data

library(dplyr)
library(igraph)
library(stringi)
library(reshape2)

# set stringsAsFactors to false, otherwise when text data is read in, it automatically converts it to a factor
# factors are nice, but only for specialized operations, in general just a "character" data type is better
options(stringsAsFactors = F)

# read in the data using read.csv
campattr <- read.csv("campattr.txt")
camp92 <- read.csv("Camp92.txt")

# fix up the names in campattr
campattr$Node <- stri_trim(campattr$Node)
camp92$time <- c(rep(1,18), rep(2, 18))

### Creating the graph using graph.data.frame #################################
camp92.el <- melt(camp92, id.vars = c('Node', 'time'))
camp92.el <- camp92.el[,c('Node','variable','value','time')]
colnames(camp92.el) <- c('source','target','weight','time')
camp92.el$source <- stri_trim(camp92.el$source)
camp92.el$target <- stri_trim(camp92.el$target)
g <- graph.data.frame(camp92.el, directed = T, vertices = campattr)
g <- simplify(g, remove.loops = T, remove.multiple = F)

save(g, file="campnet.rda")
