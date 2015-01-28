rm(list=ls())
gc()

library(igraph)
library(ggplot2)

library(scales)
library(RColorBrewer)

# load the data
load('campnet.rda')

# filter the network for only the top three picks
g.edge3 <- subgraph.edges(g, which(E(g)$weight < 4))

# renaming the weight attribute
E(g.edge3)$wt <- max(E(g.edge3)$weight) - E(g.edge3)$weight + 1
remove.edge.attribute(g.edge3, 'weight')

# time 1 and 2
g1.edge3 <- subgraph.edges(g.edge3, which(E(g.edge3)$time == 1))
g2.edge3 <- subgraph.edges(g.edge3, which(E(g.edge3)$time == 2))

# stack both time points into a list
gs <- list()
gs[[1]] <- g1.edge3
gs[[2]] <- g2.edge3

### Basic Viz #################################################################

# retain the default graphic parameters
def.par <- par()

# igraph options
igraph.options(vertex.color = 'lightblue', vertex.frame.color = 'grey50', 
               vertex.label.family = "Droid Sans", vertex.label.color="black", vertex.label.cex = 0.7, 
               edge.arrow.size = 0.5)

par(mfrow=c(1,2))
layouts <- list()
layouts[[1]] <- layout.kamada.kawai(gs[[1]])
layouts[[2]] <- layout.kamada.kawai(gs[[2]])
plot(gs[[1]], vertex.label = V(gs[[1]])$title, layout = layouts[[1]], main="Time 1")
plot(gs[[2]], vertex.label = V(gs[[2]])$title, layout = layouts[[2]], main="Time 2")

getColors <- function(x) {
  require(scales)
  ix <- floor(rescale(x, to = c(1, 100)))
  pal <- colorRampPalette(brewer.pal(8,"BrBG"))(100)
  return(pal[ix])
}

plotCentrality <- function(g, lo, vattr, ...) {
  x <- get.vertex.attribute(g, vattr)
  V(g)$color <- getColors(x)
  plot(g, vertex.label = V(g)$title, layout = lo, ...)
}

plotCentralityPair <- function(vattr, ...) {
  par(mfrow=c(1,2))
  plotCentrality(gs[[1]], layouts[[1]], vattr, main = "Time 1", ...)
  plotCentrality(gs[[2]], layouts[[2]], vattr, main = "Time 2", ...)
}

### Centrality ################################################################

gs <- lapply(gs, function(x) {
  V(x)$degree      <- degree(x, mode = "total")
  V(x)$indegree    <- degree(x, mode = "in")
  V(x)$outdegree   <- degree(x, mode = "out")
  V(x)$betweenness <- betweenness(x)
  V(x)$evcent      <- evcent(x)$vector
  V(x)$closeness   <- closeness(x)
  V(x)$flowbet     <- sna::flowbet(as.matrix(get.adjacency(x, attr="wt")))
  E(x)$betweenness <- edge.betweenness(x)
  return(x)
})

plotCentralityPair('betweenness', sub = 'Total Degree')

round(betweenness(g1.edge3, weights=rep(1, length(E(g1.edge3)))), 2)
x1 <- round(betweenness(g1.edge3), 2)
x2 <- sna::flowbet(as.matrix(get.adjacency(g1.edge3, attr = "weight")))

evcent(g1.edge3)


ggplot(data.frame(eb=edge.betweenness(gs[[1]]), wt=E(gs[[1]])$weight), aes(x=wt,y=eb)) + 
  geom_point() + geom_smooth()


ego.effective.size <- function(g, ego, ...) {
  n = neighbors(g, ego, ...)
  t = length(E(g)[to(n) & !to(ego)])
  n = length(n)
  n - (2 * t) / n
}
effective.size <- function(g, ego=NULL, ...) {
  if(!is.null(ego)) {
    return(ego.effective.size(g, ego, ...))
  }
  return(sapply(V(gs[[1]])$name, function(x) { ego.effective.size(gs[[1]], x, ...)}))
}
effective.size(gs[[1]], mode = "all")

gs <- lapply(gs, function(x) {
  
  # Centrality
  V(x)$degree      <- degree(x, mode = "total")
  V(x)$indegree    <- degree(x, mode = "in")
  V(x)$outdegree   <- degree(x, mode = "out")
  V(x)$betweenness <- betweenness(x)
  V(x)$evcent      <- evcent(x)$vector
  V(x)$closeness   <- closeness(x)
  V(x)$flowbet     <- sna::flowbet(as.matrix(get.adjacency(x, attr="wt")))
  E(x)$betweenness <- edge.betweenness(x)
  
  # Local position
  V(x)$effsize     <- effective.size(x, mode = "all")
  V(x)$constraint  <- constraint(x)
  
  # Clustering
  com <- edge.betweenness.community(x)
  V(x)$memb        <- com$membership
  
  # Whole network
  x <- set.graph.attribute(x, "density", graph.density(x))
  x <- set.graph.attribute(x, "avgpathlength", average.path.length(x))
  x <- set.graph.attribute(x, "modularity", modularity(com))
  x <- set.graph.attribute(x, "betcentralization", centralization.betweenness(x)$centralization)
  x <- set.graph.attribute(x, "degcentralization", centralization.degree(x, mode = "total")$centralization)
  x <- set.graph.attribute(x, "size", vcount(x))
  x <- set.graph.attribute(x, "edgecount", ecount(x))
    
  return(x)
})

vstats <- do.call('rbind', lapply(1:length(gs), function(x) {
  o <- get.data.frame(gs[[x]], what = 'vertices')
  o$time <- x
  return(o)
}))

estats <- do.call('rbind', lapply(1:length(gs), function(x) {
  o <- get.data.frame(gs[[x]], what = 'edges')
  return(o)
}))

gstats <- do.call('rbind', lapply(gs, function(y) {
  ga <- list.graph.attributes(y)
  sapply(ga, function(x) {
    get.graph.attribute(y, x)
  })
}))




