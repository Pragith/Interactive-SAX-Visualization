library(shiny)
library(dygraphs)
library(ggvis)
library(dplyr)
library(ggplot2)
library(xts)



shinyServer(function(input, output) {
  
  source("Functions.R")
  
  res = reactive({
    result = do.sax(paste("data/",input$dataset,".dat",sep=""), input$wlen, input$nsyms, input$asize)
    return(result)
  })
  
  output$pattern_table = renderTable({
    pattern = patternize(res())
  })

  g1 = reactive({ plot.g1(res(), nrow(res())) })
  g2 = reactive({ plot.g2(res(), nrow(res())) })
  g3 = reactive({ plot.g3(res(), nrow(res())) })
  g4 = reactive({ plot.g4(res(), nrow(res())) })
  
  output$g1_graph <- renderDygraph({  g1()  })
  output$g2_graph <- renderDygraph({  g2()  })
  output$g3_graph <- renderDygraph({  g3()  })
  output$g4_graph <- renderDygraph({  g4()  })

})