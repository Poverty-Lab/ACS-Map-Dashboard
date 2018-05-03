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

#FOR TESTING
#input <- c(); input$variable = variableList$stub[1]; input$customtype = "Count"; input$custompop = "Individual"

####  Server  ####
server <- shinyServer(function(input, output, session) {
  
  output$map <- renderPlot({
    
    dataF <- CCAsF #in future, make dependent on geog selection
    
    #download data
    var <- variableList$variableID[variableList$stub == input$variable]
    acs <- acs::acs.fetch(geography = geog, endyear = 2015, span = 5, variable = var)
    agg <- tractToCCA(x = estimate(acs), tractID = acs@geography$tract, type = input$customtype, level = input$custompop, return_df = T)
    
    #merge to map-ready dataframe
    dataF <- merge(dataF, dplyr::select(agg, CCA, x))
    
    dataF %>%
      ggplot() +
      geom_polygon(data = dataF, aes(x = long, y = lat, group = group, fill = x), color = NA, size = .25) +
      coord_map() +
      ggtitle(input$titleMap) + 
      # scale_fill_gradient(low = "#ffcccc", high = "#ff0000",  ## IN DEVELOPMENT - make colors dependent on lab branding ##
      #                     labels = comma) +
      theme(legend.title = element_blank()) +
      themeMap
    
  })
  
  output$bar <- renderPlot({
    
    data <- CCAs #in future, make dependent on geog selection
    
    #download data
    var <- variableList$variableID[variableList$stub == input$variable]
    acs <- acs::acs.fetch(geography = geog, endyear = 2015, span = 5, variable = var)
    agg <- tractToCCA(x = estimate(acs), tractID = acs@geography$tract, type = input$customtype, level = input$custompop, return_df = T)
    
    #merge to plot-ready dataframe
    data <- merge(data, dplyr::select(agg, CCA, x))
    
    ####################
    ## IN DEVELOPMENT ##
    ####################
    ## Error bars
    
    ####################

    if(input$direction == "Descending") {
      
      data <- data %>%
        dplyr::arrange(desc(x)) %>%
        head(input$nGeog)
      
      bar <- ggplot() +
        geom_bar(aes(x = reorder(data$CCA, desc(eval(data$x))), y = data$x), stat = "identity") + #, fill = "#8a0021") +
        
        ####################
        ## IN DEVELOPMENT ##
        # geom_errorbar(aes(x = reorder(data$CCA, desc(eval(data[[var]]))), ymin = data[[varmin]], ymax = data[[varmax]]), color = "#f8a429", size = 1.25, width = .5) +
        # ggtitle(input$titleBar) +
        ####################
        
        scale_y_continuous(labels = comma) +
        xlab("Community Area") + ylab(input$variable) +
        themeMOE
      
      
    } else if(input$direction == "Ascending") {
      
      data <- data %>%
        dplyr::arrange(x) %>%
        head(input$nGeog)
      
      bar <- ggplot() +
        geom_bar(aes(x = reorder(data$CCA, eval(data$x)), y = data$x), stat = "identity") + #, fill = "#8a0021") +
        
        ####################
        ## IN DEVELOPMENT ##
        # geom_errorbar(aes(x = reorder(data$CCA, desc(eval(data[[var]]))), ymin = data[[varmin]], ymax = data[[varmax]]), color = "#f8a429", size = 1.25, width = .5) +
        # ggtitle(input$titleBar) +
        ####################
        
        scale_y_continuous(labels = comma) +
        xlab("Community Area") + ylab(input$variable) +
        themeMOE
      
    }
    
    bar
    
  })
  
  output$table <- renderTable({
    
    data <- CCAs #in future, make dependent on geog selection
    
    #download data
    var <- variableList$variableID[variableList$stub == input$variable]
    acs <- acs::acs.fetch(geography = geog, endyear = 2015, span = 5, variable = var)
    agg <- tractToCCA(x = estimate(acs), tractID = acs@geography$tract, type = input$customtype, level = input$custompop, return_df = T)
    
    names(agg)[2] <- input$variable
    
    agg
    
  })
  
  ####################
  ## IN DEVELOPMENT ##
  output$save <- downloadHandler(
    filename = "plot.png",
    content = function(file) {
      ggsave(file, plot = map, device = "png")
    }
  )

  # geogOptions <- c("CCA", "Census Tract", "ZIP", "Heatmap") #make reactive such that only those available for each content option show (or others are greyed out)
  
  ####################
  
  updateSelectizeInput(session, "table", choices = tableOptions, server = TRUE, selected = "UNWEIGHTED SAMPLE COUNT OF THE POPULATION")

  output$universe <- renderText(universeList$stub[universeList$tableID == tableList$tableID[tableList$stub == input$table]])
  
  output$variableOptions <- renderUI({
    
    selectedTable <- tableList$tableID[tableList$stub == input$table]
    variables <- variableList$stub[variableList$tableID == selectedTable]

    selectizeInput("variable", "Variable from Table", choices = variables, multiple = FALSE, options = list(searchConjunction = "and"))
    
  })
  
})


# end of script #
