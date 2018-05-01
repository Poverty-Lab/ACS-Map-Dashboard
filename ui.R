#
# Author:   Isaac Ahuvia and Cristian Nuno
# Date:     May 1, 2018
# Purpose:  Create UI
#

####  Startup  ####
library( dplyr )
library( shiny )
library( shinyjs )
library( ggplot2 )
library( scales )
library( shinyBS )
library( shinythemes )
library( dygraphs )
library( plotly )
library( DT )
library( shinydashboard )
library( grDevices )
library( acs )
library( RCurl )

####  UI  ####
ui <- fluidPage(useShinyjs(),
                
                fluidRow(br()),
                
                fluidRow(
                  
                  column(width = 3,
                         
                         br(), br(),
                         
                         wellPanel("Data",
                                   
                                   selectInput("content", "Premade Plots", choices = contentOptions),
                                   textInput("custom", "Custom Plot - ACS variable given in format XXXXXX_XXX"),
                                   radioButtons("customtype", "This custom statistic is a:", choices = c("Count", "Proportion", "Mean"), inline = T),
                                   radioButtons("custompop", "This custom statistic is of which level:", choices = c("Individual", "Household"), inline = T),
                                   radioButtons("stat", "Statistic", choices = statOptions)
                                   #radioButtons("geog", "Geography", choices = geogOptions)
                                   
                         )
                         
                  ),
                  
                  column(width = 9,
                         
                         tabsetPanel(id = "tab",
                                     
                                     tabPanel("Map", id = "map", 
                                              
                                              column(width = 6,
                                                     
                                                     plotOutput("map"),
                                                     actionButton("save", "Save Graphic"),
                                                     
                                                     actionButton("showCodeMap", "Show Code"),
                                                     hidden(
                                                       div(id='mapCodeDiv',
                                                           verbatimTextOutput("mapCode")
                                                       )
                                                     )
                                                     
                                              ),
                                              
                                              column(width = 3, 
                                                     
                                                     wellPanel("Map Options",
                                                               
                                                               textInput(label = "Title", inputId = "titleMap"),
                                                               checkboxGroupInput(label = "Map Features", inputId = "mapfeatures", choices = c("Geography Labels", "Show as Percent"), inline = T, selected = NULL),
                                                               radioButtons(label = "Lab Theme", inputId = "labMap", choices = c("Poverty", "Crime"), selected = "Poverty")
                                                               
                                                     )
                                              )
                                     ),
                                     
                                     tabPanel("Bar Plot", id = "bar",
                                              
                                              column(width = 6,
                                                     
                                                     plotOutput("bar"),
                                                     actionButton("save", "Save Graphic")
                                                     
                                              ),
                                              
                                              column(width = 3,
                                                     
                                                     wellPanel("Bar Plot Options",
                                                               
                                                               textInput(label = "Title", inputId = "titleBar"),
                                                               radioButtons(label = "Direction", inputId = "direction", choices = c("Descending", "Ascending"), inline = T, selected = "Descending"),
                                                               sliderInput(label = "Number of Geographies", inputId = "nGeog", min = 0, max = 20, value = 15, round = T),
                                                               radioButtons(label = "Lab Theme", inputId = "labBar", choices = c("Poverty", "Crime"), selected = "Poverty")
                                                               
                                                     )
                                                     
                                              )
                                              
                                     ),
                                     
                                     tabPanel("Table", id = "table", 
                                              
                                              column(width = 6,
                                                     
                                                     tableOutput("table"),
                                                     actionButton("save", "Save Data")
                                                     
                                              )
                                              
                                     )
                                     
                         )
                         
                  )
                  
                )
                
) # end of UI


# end of script #
