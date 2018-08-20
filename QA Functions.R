####################
##  QA Functions  ##
####################

#Use this to set different configurements of the app when QA'ing under the hood

setInputs <- function(config = 1) {
  
  if(config == 1) {
    
    input <- c()
    input$variable <- "Asian Alone"
    input$select.table <- "Race"
    input$statToShow <- "Total"
    input$map.color.palette <- "Default"
    
  }
  
  input <<- input
  
}