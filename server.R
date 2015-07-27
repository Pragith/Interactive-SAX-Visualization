library(shiny)
library(dygraphs)
library(ggvis)
library(dplyr)
library(ggplot2)
library(xts)



shinyServer(function(input, output) {
  
  source("Functions.R")
  #breakpoints = breakpoints.generate()
  
  res = reactive({
    result = do.sax(paste(input$dataset,".dat",sep=""), input$wlen, input$nsyms, input$asize)
    return(result)
  })
  
  output$pattern_table = renderTable({
    pattern = patternize(res())
  })

  graph.params = reactive({
    plot.graphs(res(), nrow(res()))
  })
  
  output$g1_graph <- renderDygraph({  graph.params();    g1  })
  output$g2_graph <- renderDygraph({  graph.params();    g2  })
  output$g3_graph <- renderDygraph({  graph.params();    g3  })
  output$g4_graph <- renderDygraph({  graph.params();    g4  })

})