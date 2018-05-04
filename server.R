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
  
  # store user data
  # in a reactive expression
  user.data <- reactive({
    #download data
    var <- variableList$variableID[variableList$stub == input$variable]
    acs <- acs::acs.fetch(geography = geog
                          , endyear = 2015 # we should be using 2016 5-year ACS data
                          , span = 5
                          , variable = var )
    agg <- tractToCCA(x = estimate(acs)
                      , tractID = acs@geography$tract
                      , type = input$customtype
                      , level = input$custompop
                      , return_df = T )
    
    # return agg to the Global Environment
    return( agg )
  })
  
  # store fortified (tidy) data frame
  # that contains aggregated census tract statistics
  # for each CCA in a reactive expression
  fortified.data <- reactive({
    merge( x = CCAsF
           , y = user.data()
           , by = "CCA"
           , all = FALSE )
  })
  
  # store data frame
  # that contains census tract statistics
  # for each CCA in a reactive data frame
  cca.ct.data <- reactive({
    merge( x = CCAs
           , y = user.data()
           , by = "CCA"
           , all = FALSE )
  })
  
  # store map created from fortified.data()
  user.map <- reactive({
    # create map using ggplot
    ggplot() +
      geom_polygon(data = fortified.data()
                   , aes(x = long, y = lat, group = group, fill = x)
                   , color = NA, size = .25) +
      coord_map() +
      ggtitle(input$titleMap) + 
      # scale_fill_gradient(low = "#ffcccc", high = "#ff0000",  ## IN DEVELOPMENT - make colors dependent on lab branding ##
      #                     labels = comma) +
      theme(legend.title = element_blank()) +
      themeMap
  })
  
  # store barplot created from cca.ct.data()
  user.bplot <- reactive({
    # create barplot using ggplot
    if(input$direction == "Descending") {
      
      data <- 
        cca.ct.data() %>%
        dplyr::arrange(desc(x)) %>%
        head(input$nGeog)
      
      ggplot() +
        geom_bar(aes(x = reorder(data$CCA, desc(eval(data$x))), y = data$x)
                 , stat = "identity") + #, fill = "#8a0021") +
        
      ####################
      ## IN DEVELOPMENT ##
      # geom_errorbar(aes(x = reorder(data$CCA, desc(eval(data[[var]]))), ymin = data[[varmin]], ymax = data[[varmax]]), color = "#f8a429", size = 1.25, width = .5) +
      # ggtitle(input$titleBar) +
      ####################
      
      scale_y_continuous(labels = comma) +
        xlab("Community Area") + ylab(input$variable) +
        themeMOE
      
    } else if(input$direction == "Ascending") {
      
      data <- 
        cca.ct.data() %>%
        dplyr::arrange(x) %>%
        head(input$nGeog)
      
      ggplot() +
        geom_bar(aes(x = reorder(data$CCA, eval(data$x)), y = data$x)
                 , stat = "identity") + #, fill = "#8a0021") +
        
      ####################
      ## IN DEVELOPMENT ##
      # geom_errorbar(aes(x = reorder(data$CCA, desc(eval(data[[var]]))), ymin = data[[varmin]], ymax = data[[varmax]]), color = "#f8a429", size = 1.25, width = .5) +
      # ggtitle(input$titleBar) +
      ####################
      
      scale_y_continuous(labels = comma) +
        xlab("Community Area") + ylab(input$variable) +
        themeMOE
    }
  })
  
  # display user.map() in the UI
  output$map <- renderPlot({
    user.map()
  })
  
  # save the user.map()
  output$dwnld.map <- downloadHandler(
    filename = "ACS_Map_Dashboard_map.png"
    , content = function( file ){
      ggsave( filename = file
              , plot = user.map()
              , device = "png" )
    }
  )
  
  # display user.bplot() in the UI
  output$bar <- renderPlot({
    user.bplot()
  })
  
  # save the user.bplot()
  output$dwnld.bplot <- downloadHandler(
    filename = "ACS_Map_Dashboard_plot.png"
    , content = function( file ){
      ggsave( filename = file
              , plot = user.bplot()
              , device = "png" )
    }
  )
  
  output$table <- renderDataTable({
    # transfrom user.data()
    # to be dislayed on a DataTable
    datatable( data = user.data()
               , caption = "View the CCA statistics"
               , colnames = c("CCA", input$variable )
               , extensions = "Buttons"
               , options = list( dom = "Blfrtip"
                                 , buttons = list( "csv" )
                                 , lengthMenu = list( c(15, 35, -1)
                                                      , c(15, 35, "All 77") )
                                 , pageLength = 15 ) )
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
