#
# Author:   Isaac Ahuvia and Cristian Nuno
# Date:     August 21, 2018
# Purpose:  Create UI
#

####  Startup  ####
library( acs )
library( bitops )
library( DT )
library( dplyr )
library( ggplot2 )
library( mapproj )
library( RCurl )
library( scales )
library( shiny )
library( viridisLite )
library( viridis )


####  UI  ####
ui <- fluidPage(theme = "style.css",
                fluidRow(
                  
                  column(width = 3,
                         
                         br(), br(),
                         
                         wellPanel(
                                   h1("Step 1: Select a table and variable", class = "step"),

                                   selectInput( inputId = "selectTableSlim"
                                                   , label = "ACS Tables:"
                                                   , selected = "Total Population"
                                                   , choices = tableOptionsSlim
                                                   , selectize = F), 
                                   
                                   conditionalPanel(
                                     
                                     condition = "input.selectTableSlim == 'Other'",
                                     selectizeInput( inputId = "selectTable"
                                                     , label = "Other tables (press backspace to enable searching):"
                                                     , choices = tableOptions )
                                     
                                   ),
                                   
                                   textOutput( outputId = "universe"),
                                   br(),
                                   uiOutput( outputId = "variableOptions" )
                         ), 
                         
                         wellPanel(

                                   h1("Step 2: Choose a statistic to show", class = "step"),
                                   uiOutput( outputId = "statOptions" ),
                                   conditionalPanel(

                                     condition = "input.statToShow != 'Total'",
                                     uiOutput( outputId = "denomOptions" )

                                   )

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
                                                               
                                                               uiOutput( outputId = "maptitle" ),
                                                               
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
                                                     
                                                     a("README", target = "_blank", href = "https://github.com/Poverty-Lab/ACS-Map-Dashboard#acs-map-dashboard"), br(),
                                                     a("Aggregation details", target = "_blank", href = "Tract-to-Neighborhood_aggregation.pdf"),
                                                     img(src = "pl_logo_150x.png", align = "right")
                                              )
                                     ),
                                     
                                     tabPanel("Bar Plot", id = "bar",
                                              
                                              column(width = 6,
                                                     
                                                     plotOutput( outputId = "bar"),
                                                     downloadButton( outputId = "dwnld.bplot"
                                                                     , label = "Save Plot" )
                                                     
                                              ),
                                              
                                              column(width = 3,
                                                     
                                                     wellPanel(h1("Bar Plot Options"),
                                                               
                                                               uiOutput( outputId = "bartitle" ),
                                                               
                                                               radioButtons(label = "Direction"
                                                                            , inputId = "direction"
                                                                            , choices = c("Descending", "Ascending")
                                                                            , inline = TRUE
                                                                            , selected = "Descending"),
                                                               
                                                               sliderInput(label = "Number of Geographies"
                                                                           , inputId = "nGeog"
                                                                           , min = 0
                                                                           , max = 77
                                                                           , value = 15
                                                                           , round = TRUE ),
                                                               
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
                                                     
                                                     a("README", target = "_blank", href = "https://github.com/Poverty-Lab/ACS-Map-Dashboard#acs-map-dashboard"), br(),
                                                     a("Aggregation details", target = "_blank", href = "Tract-to-Neighborhood_aggregation.pdf"),
                                                     img(src = "pl_logo_150x.png", align = "right")
                                              )
                                              
                                     ),
                                     
                                     tabPanel("Table", id = "table", 
                                              
                                              column(width = 6,
                                                     
                                                     br(),
                                                     dataTableOutput( outputId = "dwnld.table" )
                                                     
                                              ),
                                              
                                              column(width = 3,
                                                     
                                                     wellPanel(h1("Table Options"),
                                                               
                                                               radioButtons( label = "Round"
                                                                            , inputId = "round"
                                                                            , choices = c("Round", "Don't Round")
                                                                            , inline = TRUE
                                                                            , selected = "Round" )

                                                     ), 
                                                     
                                                     a("README", target = "_blank", href = "https://github.com/Poverty-Lab/ACS-Map-Dashboard#acs-map-dashboard"), br(),
                                                     a("Aggregation details", target = "_blank", href = "Tract-to-Neighborhood_aggregation.pdf"),
                                                     img(src = "pl_logo_150x.png", align = "right")
                                                     
                                              )
                                              
                                     )
                                     
                         )
                         
                  )
                  
                )
                
) # end of UI


# end of script #
