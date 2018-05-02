#
# Author:   Isaac Ahuvia and Cristian Nuno
# Date:     May 1, 2018
# Purpose:  Create Server
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

####  Server  ####
server <- shinyServer(function(input, output, session) {
  
  output$map <- renderPlot({
    
    dataF <- dfCCAF #in future, make dependent on geog selection
    
    var <- variableList$variableID[variableList$stub == input$variable]
    acs <- acs::acs.fetch(geography = geog, endyear = 2015, span = 5, variable = var)
    agg <- tractToCCA(x = estimate(acs), tractID = acs@geography$tract, type = input$customtype, level = input$custompop, return_df = T)
    dataF <- merge(dataF, dplyr::select(agg, CCA, x))
    
    dataF %>%
      ggplot() +
      geom_polygon(data = dataF, aes(x = long, y = lat, group = group, fill = x), color = NA, size = .25) +
      coord_map() +
      ggtitle(input$titleMap) + 
      # scale_fill_gradient(low = "#ffcccc", high = "#ff0000",
      #                     labels = comma) +
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
  
  updateSelectizeInput(session, "table", choices = tableOptions, server = TRUE, selected = "UNWEIGHTED SAMPLE COUNT OF THE POPULATION")

  output$universe <- renderText(universeList$stub[universeList$tableID == tableList$tableID[tableList$stub == input$table]])
  
  
  output$variableOptions <- renderUI({
    
    selectedTable <- tableList$tableID[tableList$stub == input$table]
    variables <- variableList$stub[variableList$tableID == selectedTable]

    selectizeInput("variable", "Variable from Table", choices = variables, multiple = FALSE, options = list(searchConjunction = "and"))
    
  })
  
  
  # output$variableOptions <- renderUI({
  #   variableList$stub[variableList$tableID == tableList$tableID[tableList$stub == input$table]]
  # })
  # updateSelectizeInput(session, "variable", choices = variableOptions, server = TRUE)
  # 
  })


# end of script #
