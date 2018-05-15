#
# Author:   Isaac Ahuvia and Cristian Nuno
# Date:     May 1, 2018
# Purpose:  Create UI
#

####  Startup  ####
library( acs )
library( bitops )
library( DT )
library( dplyr )
library( ggplot2 )
library( RCurl )
library( scales )
library( shiny )
library( viridisLite )
library( viridis )
library( mapproj )


####  UI  ####
ui <- fluidPage(theme = "style.css",
                fluidRow(
                  
                  column(width = 3,
                         
                         br(), br(),
                         
                         wellPanel(
                                   h1("Step 1: Select a table and variable", class = "step"),
                                   p("ACS Table", class = "name"),
                                   selectizeInput("table", label = "Press backspace to enable searching", selected = "Total Population", choices = tableOptions), #selected = "Total Population",
                                   textOutput("universe"),
                                   br(),
                                   shiny::uiOutput( outputId = "variableOptions" )
                         ), 
                         
                         wellPanel(
                                   h1("Step 2: Confirm the variable type and population", class = "step"),
                                   radioButtons("varType", "This variable is a:", choices = c("Count", "Proportion", "Mean"), inline = T),
                                   radioButtons("varPop", "This variable is of which population:", choices = c("Individual", "Household", "Housing Unit"), inline = T)
                         ),
                         
                         wellPanel(
                                   h1("Step 3: Choose a statistic to show", class = "step"),
                                   shiny::uiOutput( outputId = "statToShow" )
                                   
                         )
                         
                  ),
                  
                  column(width = 9,
                         
                         tabsetPanel(id = "tab",
                                     
                                     tabPanel("Map", id = "map", 
                                              
                                              column(width = 6,
                                                     
                                                     plotOutput("map"),
                                                     downloadButton( outputId = "dwnld.map"
                                                                     , label = "Save Map" )
                                                     
                                              ),
                                              
                                              column(width = 3, 
                                                     
                                                     wellPanel(h1("Map Options"),
                                                               
                                                               textInput(label = "Title", inputId = "titleMap"),
                                                               
                                                               radioButtons(label = "Choose a color palette:"
                                                                            , inputId = "map.color.palette"
                                                                            , choices = c("Default"
                                                                                          , "Crime Lab"
                                                                                          , "Education Lab"
                                                                                          , "Energy & Environment Lab"
                                                                                          , "Health Lab"
                                                                                          , "Poverty Lab" )
                                                                            , selected = "Default" )
                                                               
                                                     ), 
                                                     
                                                     img(src = "pl_logo_150x.png", align = "right")
                                              )
                                     ),
                                     
                                     tabPanel("Bar Plot", id = "bar",
                                              
                                              column(width = 6,
                                                     
                                                     plotOutput("bar"),
                                                     downloadButton( outputId = "dwnld.bplot"
                                                                     , label = "Save Plot" )
                                                     
                                              ),
                                              
                                              column(width = 3,
                                                     
                                                     wellPanel(h1("Bar Plot Options"),
                                                               
                                                               textInput(label = "Title", inputId = "titleBar"),
                                                               radioButtons(label = "Direction"
                                                                            , inputId = "direction"
                                                                            , choices = c("Descending", "Ascending")
                                                                            , inline = T
                                                                            , selected = "Descending"),
                                                               sliderInput(label = "Number of Geographies"
                                                                           , inputId = "nGeog"
                                                                           , min = 0
                                                                           , max = 77
                                                                           , value = 15
                                                                           , round = T),
                                                               radioButtons(label = "Choose a color palette:"
                                                                            , inputId = "bplot.color.palette"
                                                                            , choices = c("Default"
                                                                                          , "Crime Lab"
                                                                                          , "Education Lab"
                                                                                          , "Energy & Environment Lab"
                                                                                          , "Health Lab"
                                                                                          , "Poverty Lab" )
                                                                            , selected = "Default" )
                                                               
                                                     ), 
                                                     
                                                     img(src = "pl_logo_150x.png", align = "right")
                                                     
                                              )
                                              
                                     ),
                                     
                                     tabPanel("Table", id = "table", 
                                              
                                              column(width = 6,
                                                     
                                                     br(),
                                                     dataTableOutput( outputId = "table" )
                                                     
                                              ),
                                              
                                              column(width = 3,
                                                     
                                                     wellPanel(h1("Table Options"),
                                                               
                                                               radioButtons(label = "Round", inputId = "round", choices = c("Round", "Don't Round"), inline = T, selected = "Round")

                                                     ), 
                                                     
                                                     img(src = "pl_logo_150x.png", align = "right")
                                                     
                                              )
                                              
                                     )
                                     
                         )
                         
                  )
                  
                )
                
) # end of UI


# end of script #
