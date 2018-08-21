####################
##  QA Functions  ##
####################

#Use this to set different configurements of the app when QA'ing under the hood

setInputs <- function(config = 1) {
  
  input <- c()
  
  if(config == 1) {
    
    input$variable <- "Total"
    input$selectTableSlim <- "Total Population"
    input$statToShow <- "Total"
    input$map.color.palette <- "Default"

  } else if(config == 2) {
    
    input$variable <- "Asian Alone"
    input$selectTableSlim <- "Other"
    input$selectTable <- "Race"
    input$statToShow <- "Total"
    input$map.color.palette <- "Default"
    
  } else if(config == 3) {
    
    input$variable <- "Total"
    input$selectTableSlim <- "Language Spoken At Home By Ability To Speak English For The Population 5 Years And Over"
    input$statToShow <- "Total"
    input$map.color.palette <- "Default"
    
  }
  
  input <<- input
  
}