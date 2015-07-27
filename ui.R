library(dygraphs)
#
#
# 
# Input:
#   Sliders:
#         
# 
# 
# Output:
#   G1 - Plot the Actual dataset graph
#   G2 - Plot the Normalized graph
#   G3 - Plot the PAA step graph
#   G4 - Superimposed PAA and Normalized graph
#   Subsequence Tree table (Patternized)
# 
# 
# 






library(shiny)

shinyUI(fluidPage(

  # Application title
  titlePanel("Interactive SAX Visualization"),

  # Sidebar with a slider input for number of bins
  sidebarLayout(
    sidebarPanel(
      
      ##  Dataset Dropdown
      selectInput("dataset", 
                  "Dataset:", 
                  c("ecg_anomaly1","ecg_anomaly2","ecg_anomaly3","h_ref","h_test","power_data","power_short"),
                  selected = "h_test",
                  multiple = FALSE)
      
      ##  wlen input
      ,numericInput("wlen",
                   "Window Length:",
                   value = 250)
      
      ##  nsyms input
      ,numericInput("nsyms",
                   "Number of symbols (length):",
                   value = 4)
      
      ##  asize input
      ,numericInput("asize",
                    "Alphabet Size (a,b,c,d...):",
                    value = 4)
      
#       ,sliderInput("bins",
#                   "Number of bins:",
#                   min = 1,
#                   max = 50,
#                   value = 30)
      ,tableOutput("pattern_table")
    ),

    # Show a plot of the generated distribution
    mainPanel(
      #tableOutput("pattern_table")
      dygraphOutput("g4_graph")
      ,dygraphOutput("g3_graph")
      ,dygraphOutput("g1_graph")
      ,dygraphOutput("g2_graph")
    )
  )
))
