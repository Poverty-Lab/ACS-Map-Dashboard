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
library( lettercase )
library( RCurl )
library( scales )
library( shiny )


####  UI  ####
ui <- fluidPage( fluidRow(br()),
                
                fluidRow(
                  
                  column(width = 3,
                         
                         br(), br(),
                         
                         wellPanel("Data",
                                   
                                   selectizeInput("table", "ACS Table", choices = tableOptions, multiple = FALSE, options = list(searchConjunction = "and")),
                                   textOutput("universe"),
                                   
                                   shiny::uiOutput( outputId = "variableOptions" ),
                                   
                                   
                                   radioButtons("varType", "This variable is a:", choices = c("Count", "Proportion", "Mean"), inline = T),
                                   radioButtons("varPop", "This variable is of which population:", choices = c("Individual", "Household", "Housing Unit"), inline = T),

                                   shiny::uiOutput( outputId = "statToShow" )
                                   
                                   ################################
                                   ## IN DEVELOPMENT - WISH LIST ##
                                   #radioButtons("geog", "Geography", choices = geogOptions)
                                   ################################
                                   
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
                                                     
                                                     wellPanel("Map Options"#,
                                                               
                                                               ####################
                                                               ## IN DEVELOPMENT ##
                                                               # textInput(label = "Title", inputId = "titleMap"),
                                                               # checkboxGroupInput(label = "Map Features", inputId = "mapfeatures", choices = c("Geography Labels", "Show as Percent"), inline = T, selected = NULL),
                                                               # radioButtons(label = "Lab Theme", inputId = "labMap", choices = c("Poverty", "Crime"), selected = "Poverty")
                                                               ####################
                                                               
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
                                                               
                                                               ####################
                                                               ## IN DEVELOPMENT ##
                                                               # textInput(label = "Title", inputId = "titleBar"),
                                                               ####################
                                                               
                                                               radioButtons(label = "Direction", inputId = "direction", choices = c("Descending", "Ascending"), inline = T, selected = "Descending"),
                                                               sliderInput(label = "Number of Geographies", inputId = "nGeog", min = 0, max = 20, value = 15, round = T)#,
                                                               
                                                               ####################
                                                               ## IN DEVELOPMENT ##
                                                               # radioButtons(label = "Lab Theme", inputId = "labBar", choices = c("Poverty", "Crime"), selected = "Poverty")
                                                               ####################
                                                               
                                                     )
                                                     
                                              )
                                              
                                     ),
                                     
                                     tabPanel("Table", id = "table", 
                                              
                                              column(width = 6,
                                                     
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
