####################################
##  City Data Graphics Dashboard  ##
####################################

#WELGUS: https://welgus-apps.shinyapps.io/by_region_year/
#Example ACS variable: B07008_024

####  Startup  ####
rm(list = ls())
library(dplyr)
library(shiny)
library(shinyjs)
library(ggplot2)
library(scales)
library(shinyBS)
library(shinythemes)
library(dygraphs)
library(plotly)
library(DT)
library(shinydashboard)
library(grDevices)
library(acs)

## Source aggregation function and plot themes
setwd( dir = "/export/code_library/R/UL_packages/acs_map_dashboard/R/" )

source( file = "00_Aggregation Function.R" )
source( file = "00_Themes.R")

####  Load data  ####
## Load prepared datasets (do data prep outside of app)
# load necessary data
setwd( dir = "/export/code_library/R/UL_packages/acs_map_dashboard/Data/" )

variables <- 
  read.csv( file = "Preselected Variables.csv"
            , header = TRUE
            , stringsAsFactors = FALSE )
CCA <- 
  read.csv( file = "CCA Statistics.csv"
            , header = TRUE
            , stringsAsFactors = FALSE )

load( file = "CCA Statistics Fortified.RData" )

# Set options for preset dataframes
contentOptions <- paste0( variables$Population
                          , " - "
                          , variables$Statistic ) # add headers from variables$category 

statOptions <- c("Total", "Percent", "Per 100k")

#geogOptions <- c("CCA", "Census Tract", "ZIP", "Heatmap") #make reactive such that only those available for each content option show (or others are greyed out)


####  Prime ACS Download Capabilities  ####
geog <- readRDS( file = "Cook_County_GeoSet.rds" )



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
    
)


####  Server  ####
server <- shinyServer(function(input, output) {

  output$map <- renderPlot({
    
    dataF <- dfCCAF #in future, make dependent on geog selection
    
    if(nchar(input$custom) == 10) {
      acs <- acs::acs.fetch(geography = geog, endyear = 2015, span = 5, variable = input$custom)
      agg <- tractToCCA(x = estimate(acs), tractID = acs@geography$tract, type = input$customtype, level = input$custompop, return_df = T)
      dataF <- merge(dataF, dplyr::select(agg, CCA, x))
      var <- "x"
    } else {
      var <- variables$App.Name[paste0(variables$Population, " - ", variables$Statistic) == input$content] #in future, make dependent on stat selection as well
    }
    
    dataF %>%
      ggplot() +
      geom_polygon(data = dataF, aes(x = long, y = lat, group = group, fill = eval(parse(text = var))), color = NA, size = .25) +
      coord_map() +
      ggtitle(input$titleMap) + 
      scale_fill_gradient(low = "#ffcccc", high = "#ff0000",
                          labels = comma) +
      theme(legend.title = element_blank()) +
      themeMap
    
  })
  
  
  observeEvent(input$showCodeMap, {
    toggle('mapCodeDiv')
    output$mapCode <- renderText({
      
      paste0(
'library(ggplot2)
setwd( dir = "/export/code_library/R/UL_packages/acs_map_dashboard/R/" )
source( file "00_Themes.R" )
setwd( dir = "/export/code_library/R/UL_packages/acs_map_dashboard/Data)
load( file =', gsub( pattern = " ", replacement = "", x = input$geog ), '_F.RData" )

dfCCAF %>%
  ggplot() +
  geom_polygon(data = ',paste0(gsub(" ", "", input$geog), "_F"),', aes(x = long, y = lat, group = group, fill = ',variables$App.Name[paste0(variables$Population, " - ", variables$Statistic) == input$content],', size = .25)) +
  coord_map() +
  ggtitle(', paste0( "'", input$titleMap, "'" ), ' ) + 
  scale_fill_gradient(low = "#ffcccc", high = "#ff0000",
                      labels = comma) +
  theme(legend.title = element_blank()) +
  themeMap'
      )
      
    })
  })
  
  
  output$bar <- renderPlot({
    
    data <- CCA #in future, make dependent on geog selection
    var <- variables$App.Name[paste0(variables$Population, " - ", variables$Statistic) == input$content] #in future, make dependent on stat selection as well
    varmin <- paste0(var, ".5..")
    varmax <- paste0(var, ".95..")

    if(input$direction == "Descending") {
      
      data <- data %>%
        dplyr::arrange(desc(data[[var]])) %>%
        head(input$nGeog)
      bar <- ggplot() +
          geom_bar(aes(x = reorder(data$CCA, desc(eval(data[[var]]))), y = data[[var]]), stat = "identity", fill = "#8a0021") +
          geom_errorbar(aes(x = reorder(data$CCA, desc(eval(data[[var]]))), ymin = data[[varmin]], ymax = data[[varmax]]), color = "#f8a429", size = 1.25, width = .5) +
          scale_y_continuous(labels = comma) +
          ggtitle(input$titleBar) +
          xlab("Community Area") + ylab(input$content) +
          themeMOE
      
      
    } else if(input$direction == "Ascending") {
      
      data <- data %>%
        dplyr::arrange(data[[var]]) %>%
        head(input$nGeog)
      bar <- ggplot() +
        geom_bar(aes(x = reorder(data$CCA, eval(data[[var]])), y = data[[var]]), stat = "identity", fill = "#8a0021") +
        geom_errorbar(aes(x = reorder(data$CCA, eval(data[[var]])), ymin = data[[varmin]], ymax = data[[varmax]]), color = "#f8a429", size = 1.25, width = .5) +
        scale_y_continuous(labels = comma) +
        ggtitle(input$titleBar) +
        xlab("Community Area") + ylab(input$content) +
        themeMOE
      
    }
  
    bar
    
  })
  
  output$table <- renderTable({
    
    data <- CCA #in future, make dependent on geog selection
    
    if(nchar(input$custom) == 10) {
      acs <- acs::acs.fetch(geography = geog, endyear = 2015, span = 5, variable = input$custom)
      data$x <- tractToCCA(x = estimate(acs), tractID = acs@geography$tract, type = input$customtype, level = input$custompop, return_df = F)
      var <- "x"
      varname <- acs@acs.colnames
    } else {
      var <- variables$App.Name[paste0(variables$Population, " - ", variables$Statistic) == input$content] #in future, make dependent on stat selection as well
      varname <- input$content
    }

    vars = c("CCA", var)
    
    table <- data %>%
      dplyr::select_(.dots = vars)
    
    names(table) <- c("CCA", varname)
    
    table
    
  })
  
  output$save <- downloadHandler(
    filename = "plot.png",
    content = function(file) {
      ggsave(file, plot = map, device = "png")
    }
  )
  
  # output$save <- downloadHandler(
  #   filename = "plot.png",
  #   content = function(file) {
  #     device <- function(..., width, height) {
  #       grDevices::png(..., width = width, height = height, res = 300, units = "in")
  #     }
  #     ggsave(file, plot = function () {map}, device = device)
  #   }
  # )
  
  contentOptions <- c("Children Under 5 in Poverty",
                      "Homicides")
  geogOptions <- c("CCA", "Census Tract", "ZIP", "Heatmap") #make reactive such that only those available for each content option show (or others are greyed out)
  
})



####  App  ####
shinyApp(ui = ui, server = server)