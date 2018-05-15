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
ui <- fluidPage( fluidRow(br()),
                
                fluidRow(
                  
                  column(width = 3,
                         
                         br(), br(),
                         
                         wellPanel("Data",
                                   
                                   textOutput("instructions"),
                                   selectizeInput("table", label = "ACS Table", selected = "Total Population", choices = tableOptions), #selected = "Total Population",
                                   textOutput("universe"),
                                   br(),
                                   shiny::uiOutput( outputId = "variableOptions" ),
                                   radioButtons("varType", "This variable is a:", choices = c("Count", "Proportion", "Mean"), inline = T),
                                   radioButtons("varPop", "This variable is of which population:", choices = c("Individual", "Household", "Housing Unit"), inline = T),

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
                                                     
                                                     wellPanel("Map Options",
                                                               
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
                                                               
                                                     )
                                              )
                                     ),
                                     
                                     tabPanel("Bar Plot", id = "bar",
                                              
                                              column(width = 6,
                                                     
                                                     plotOutput("bar"),
                                                     downloadButton( outputId = "dwnld.bplot"
                                                                     , label = "Save Plot" )
                                                     
                                              ),
                                              
                                              column(width = 3,
                                                     
                                                     wellPanel("Bar Plot Options",
                                                               
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
                                                               
                                                     )
                                                     
                                              )
                                              
                                     ),
                                     
                                     tabPanel("Table", id = "table", 
                                              
                                              column(width = 6,
                                                     
                                                     br(),
                                                     dataTableOutput( outputId = "table" )
                                                     
                                              ),
                                              
                                              column(width = 3,
                                                     
                                                     wellPanel("Table Options",
                                                               
                                                               radioButtons(label = "Round", inputId = "round", choices = c("Round", "Don't Round"), inline = T, selected = "Round")

                                                     )
                                                     
                                              )
                                              
                                     )
                                     
                         )
                         
                  )
                  
                )
                
) # end of UI


# end of script #
