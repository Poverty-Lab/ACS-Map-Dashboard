#
# Author:   Isaac Ahuvia and Cristian Nuno
# Date:     May 1, 2018
# Purpose:  Create Server
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


#FOR TESTING
#input <- c(); input$variable = variableList$stub[1]; input$varType = "Count"; input$varPop = "Individual"
#x = estimate(acs); tractID = acs@geography$tract; type = input$varType; level = input$varPop; return_df = T

####  Server  ####
server <- shinyServer(function(input, output, session) {
  
  # store user data
  # in a reactive expression
  user.data <- reactive({
    # require that the three inputs needed to fetch ACS data are not NULL
    # note: used to hide initial error message when data is loading
    validate( need( expr = input$variable
                    , message = "Please select a variable. Note: data is being downloaded over the internet so please be patient." )
              , need( expr = input$varType
                      , message = "Please specify this variable's type." )
              , need( expr = input$varPop
                       , message = "Please specify this variable's population." ) )
    
    #download data
    var <- variableList$variableID[variableList$stub == input$variable]
    
    acs <- acs::acs.fetch(geography = geog
                          , endyear = 2015 # we should be using 2016 5-year ACS data
                          , span = 5
                          , variable = var )
    agg <- tractToCCA(x = estimate(acs)
                      , tractID = acs@geography$tract
                      , type = input$varType
                      , level = input$varPop
                      , return_df = T )
    
    #also grab a total population estimate for this variable, to be used for calculating percent & per 100k outputs,
    #by downloading the Bxxxxx_001 variant of whatever table
    #Since we only need this when input$varType != "Total", let's only run it in those cases
    if(input$statToShow != "Total") {
    
    var.pop <- paste0(strsplit(var, "_")[[1]][1], "_001")
    acs.pop <- acs::acs.fetch(geography = geog
                          , endyear = 2015 # we should be using 2016 5-year ACS data
                          , span = 5
                          , variable = var.pop )
    agg.pop <- tractToCCA(x = estimate(acs.pop)
                      , tractID = acs.pop@geography$tract
                      , type = input$varType
                      , level = input$varPop
                      , return_df = T )
    agg.pop <- dplyr::rename(agg.pop, x.pop = x)
    
    # merge on x.pop
    if(input$statToShow == "Percent") {
      
      agg$x <- agg$x / agg.pop$x.pop
      agg <- dplyr::select(agg, CCA, x)
      
    } else if(input$statToShow == "Per 100k") {
      
      agg$x <- (agg$x / agg.pop$x.pop) * 100000
      agg <- dplyr::select(agg, CCA, x)
      
    }
    
    }
    
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
    map <- ggplot() +
      geom_polygon(data = fortified.data()
                   , aes(x = long, y = lat, group = group, fill = x)
                   , color = NA, size = .25) +
      coord_map() +
      ggtitle(input$titleMap) + 
      
      ####################
      ## IN DEVELOPMENT ##
      # scale_fill_gradient(low = "#ffcccc", high = "#ff0000",  ## IN DEVELOPMENT - make colors dependent on lab branding ##
      #                     labels = comma) +
      ####################
      
      theme(legend.title = element_blank()) +
      themeMap
    
    if(input$varPop %in% c("Count", "Mean")) {
      
      if(input$statToShow %in% c("Total", "Per 100k")) {
        
        map <- map + themeTot.100k
        
      } else if(input$statToShow == "Percent") {
        
        map <- map + themePct
        
      }
      
    }
    
    map
    
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
    
    if(input$round == "Round") {
      
      if(input$varType == "Count") {
        
        nDigits = 0
        
      } else if(input$varType %in% c("Proportion", "Mean")) {
        
        nDigits = 2
        
      }
      
    } else if(input$round == "Don't Round") {
      
      nDigits = 12
      
    }
    
    # transfrom user.data()
    # to be dislayed on a DataTable
    datatable( data = user.data()
               , caption = "Table 1. 2015 5-Year ACS statistics by CCA"
               , colnames = c("CCA", input$variable )
               , extensions = "Buttons"
               , rownames = F
               , options = list( dom = "Blfrtip"
                                 , buttons = list( "csv" )
                                 , lengthMenu = list( c(15, 35, -1)
                                                      , c(15, 35, "All 77") )
                                 , pageLength = 15 ) ) %>%
      DT::formatRound(columns = "x", digits = nDigits)

  })
  
  ####################
  ## IN DEVELOPMENT ##
  output$save <- downloadHandler(
    filename = "plot.png",
    content = function(file) {
      ggsave(file, plot = map, device = "png")
    }
  )
  ####################
  
  updateSelectizeInput(session, "table", choices = tableOptions, server = TRUE, selected = "UNWEIGHTED SAMPLE COUNT OF THE POPULATION")

  output$universe <- renderText(universeList$stub[universeList$tableID == tableList$tableID[tableList$stub == input$table]])
  
  output$variableOptions <- renderUI({
    
    selectedTable <- tableList$tableID[tableList$stub == input$table]
    variables <- variableList$stub[variableList$tableID == selectedTable]

    selectizeInput("variable", "Variable from Table", choices = variables, multiple = FALSE, options = list(searchConjunction = "and"))
    
  })
  
  output$statToShow <- renderUI({
    
    if(input$varType == "Count") {
      
      statChoices <- c("Total", "Percent", "Per 100k")
      
    } else {
      
      statChoices <- "Total"
      
    }
    
    selectInput("statToShow", "Statistic to Show:", choices = statChoices, selected = "Total")
    
  })
  
})


# end of script #
