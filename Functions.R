###############################################################################

### Function - do.sax 
###   Params: data (only filename), wlen, nsyms, asize
###   Returns: window.data
###   Example: do.sax("h_test.dat", 250, 4, 4)
do.sax = function(data,wlen, nsyms, asize){
  data = read.csv(data)
  windows = as.integer(nrow(data)/wlen)+1
  window.data = array(list(), dim=c(windows,7))
  q = (qnorm(seq(0, 1, 1/asize))) ##  To calculate breakpoints based on asize
  
  for (i in 1:windows){
    
    ##  Insert window_id
    window.data[[i,1]] = i
    
    ##  Define data range based on windows
    lower = (i-1)*wlen
    higher = i*wlen
    
    ##  Insert unit range (for tracking original data)
    window.data[[i,2]] = lower:higher
    
    ##  Take data
    d = data.frame(data[lower:higher,])
    d = na.omit(d)
    colnames(d) = "value" ##  Rename column

    ##  Insert original data (for tracking original data)
    window.data[[i,3]] = d$value
        
    ##  Normalize
    m = mean(d$value)
    s = sd(d$value)
    
    ##  Push normalized values to window.data
    d$norm = sapply(d$value,function(x){ normalize(x,m,s) })
    window.data[[i,4]] = sapply(d$value,function(x){ normalize(x,m,s) })
    
    ##  Get Piecewise Aggregate Approximation (PAA)
    PAA = array(0, nsyms)
    for (j in 1:nsyms) {
      PAA[j] = mean(d$norm[round((j - 1) * length(d$norm)/nsyms + 1):round(j * length(d$norm)/nsyms)])
    }
    
    ##  Push PAA values to window.data
    window.data[[i,5]] = PAA
    
    ##  Push Scaled PAA values to window.data
    window.data[[i,6]] = scaled.paa(PAA, wlen)
    
    ##  Save the SAX string
    window.data[[i,7]] = paste(letters[sapply(unlist(PAA), pos, v = q)], collapse = "")
  }
  
  ##  Prettify window.data
  window.data = data.frame(window.data)
  window.data$X7 = as.character(window.data$X7)
  colnames(window.data) = c("window_id","range","data","norm","paa","scaled_paa","band")
  
  return (window.data)
}


###############################################################################

### Function - patternize 
###   Params: window.data
###   Returns: pattern (bands and counts)
patternize = function(window.data){
  pattern = window.data %>% 
    group_by(band) %>% 
    summarise(count = n()) %>% 
    arrange(desc(count))
  return (pattern)
}

###############################################################################

### Function - Normalize 
###   Params: Value, Mean and SD
###   Returns: Normalized value
normalize = function(val,m,s){  return ((val-m)/s)  }

###############################################################################

### Function - plot.graphs 
###   Params: x (data), wlen
###   Returns: g1,g2,g3,g4
plot.graphs = function(x, wlen){

  #   G1 - Plot the Actual dataset graph
  g1.data = ts(get.list.values(x$data, wlen), start = c(1,100000))
  g1 <<- dygraph(g1.data, main="Original Dataset", group="anomaly_graph") %>% dyRangeSelector()
  
  #   G2 - Plot the Normalized graph
  g2.data = ts(get.list.values(x$norm, wlen), start = c(1,100000))
  g2 <<- dygraph(g2.data, main="Normalized Dataset", group="anomaly_graph") %>% dyRangeSelector()
  
  #   G3 - Plot the PAA step graph
  g3.data = ts(get.list.values(x$paa, wlen), start = c(1,100000))
  g3 <<- dygraph(g3.data, main="PAA Step Graph") %>% dyOptions(stepPlot = TRUE) %>% dyRangeSelector()
  
  #   G4 - Superimposed PAA and Normalized graph
  d1 = ts(get.list.values(x$norm, wlen)[1:length(get.list.values(x$scaled_paa,wlen))], start = c(1,100000))
  d2 = ts(get.list.values(x$scaled_paa, wlen), start = c(1,100000))
  g4.data = cbind(as.xts(d1),as.xts(d2))
  g4 <<- dygraph(g4.data, main="Superimposed PAA on Normalized graph", group="anomaly_graph") %>% dyRangeSelector()
  
}

###############################################################################

### Function - pos 
###   Params: Send the qnorm values
###   Returns: Position of the breakpoint where it belongs
pos = function(t, v) {  which.max(v[v <= t])  }

###############################################################################

### Function - scaled.paa 
###   Params: paa_values, length of original dataset
###   Returns: Repeated paa_values into equi-length of dataset
scaled.paa = function(paa, data.length){
  paa.len = nrow(paa)
  x = list()
  for(i in 1:paa.len){
    x = c(x,rep(paa[[i]], as.integer(data.length/paa.len)))
  }
  if (length(x) < data.length){
    x[length(x):data.length] = 0 
  }
  return (x)
}

###############################################################################

### Function - get.list.values
###   Params: data, wlen
###   Returns: Unset list values for plotting
get.list.values = function(data, wlen){
  l <<- list()
  for (i in 1:wlen){
    l <<- c(l,data[[i]])
  }
  return (as.numeric(l))
}

###############################################################################