#
# Author:   Isaac Ahuvia and Cristian Nuno
# Date:     August 21, 2018
# Purpose:  Create Server
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
library( shinycssloaders )
library( shinyjs )
library( shinydashboard )


####  Server  ####
server <- function( input, output, session ) {

  # store selected table
  user.table <- reactive({
    
    req(input$selectTableSlim, input$selectTable)
    
    table <- if_else(input$selectTableSlim == "Other", input$selectTable, input$selectTableSlim)
    
    return(table)
    
  })
  
  user.tableID <- reactive({
    
    req(user.table())
    
    tableID <- unique(variables$tableID[variables$tableStub == user.table()])
    
    return(tableID)
    
  })

  # store selected variable
  user.variable <- reactive({
    
    req(user.table())
    
    var <- variables$variableID[variables$variableName == input$variable &
                                variables$tableStub == user.table()]
          
    return(var)
    
  })
  
  # store labels based on user input
  user.labels <- reactive({
    
    req(input$statToShow)
  
      if(input$statToShow %in% c("Total", "Per 100k", "Per Individual Unit")) {

        scales::comma_format()

      } else if(input$statToShow == "Percent") {

        scales::percent_format()
      
      }

    })
  
  # store user color for map
  user.map.color <- reactive({
    
    req(input$map.color.palette)
  
    switch( EXPR = input$map.color.palette
            , Default                    = scale_fill_viridis( direction = -1
                                                               , option = "magma"
                                                               , labels = user.labels() ) 
            , `Crime Lab`                = scale_fill_gradient( low = "#F1F1F1"
                                                                , high = "#350E20"
                                                                , labels = user.labels() )
            , `Education Lab`            = scale_fill_gradient( low = "#F1F1F1"
                                                                , high = "#C16622"
                                                                , labels = user.labels() )
            , `Energy & Environment Lab` = scale_fill_gradient( low = "#F1F1F1"
                                                                , high = "#8A9045"
                                                                , labels = user.labels() )
            , `Health Lab`               = scale_fill_gradient( low = "#F1F1F1"
                                                                , high = "#155F83"
                                                                , labels = user.labels() )
            , `Poverty Lab`              = scale_fill_gradient( low = "#F1F1F1"
                                                                , high = "#FFA319"
                                                                , labels = user.labels() ) )
  })
  
  # store user color for barplot
  user.bplot.color <- reactive({
    
    req(input$bplot.color.palette)
    
    switch( EXPR = input$bplot.color.palette
            , Default                    = "#01010E"
            , `Crime Lab`                = "#350E20"
            , `Education Lab`            = "#C16622"
            , `Energy & Environment Lab` = "#8A9045"
            , `Health Lab`               = "#155F83"
            , `Poverty Lab`              = "#FFA319" )
  })
  
  # store user color for MOE color
  # which is the complimentary color
  # based on user.bplot.color()
  user.moe.color <- reactive({
    
    req(input$bplot.color.palette)
    
    switch( EXPR = input$bplot.color.palette
            , Default                    = "#F8A429"
            , `Crime Lab`                = "#F8A429"
            , `Education Lab`            = "#227DC1"
            , `Energy & Environment Lab` = "#01010E"
            , `Health Lab`               = "#F8A429"
            , `Poverty Lab`              = "#1975FF" )
  })
  
  # store digit to be used when 
  # the user rounds the data
  # seen in the "Table" tab
  user.digit <- reactive({
    
    req(input$round, statToShow)
    
    if(input$round == "Round") {
      
        if(input$statToShow %in% c("Total", "Per 100k")) {
          
          # return zero
          0
          
        } else if(input$statToShow == "Percent") {
          
          # return two
          2
          
        }
      
    } else if(input$round == "Don't Round") {
      
      # return 12
      # note: this is a safe number since we don't plan on having estimates in the trillions
      12
      
    }
    
  })
  
  # query the ACS API
  # based on the ACS Table and store the results
  user.data <- reactive({

    req(input$variable, user.table(), user.tableID(), input$statToShow)
    
    # require that the three inputs needed to fetch ACS data are not NULL
    # note: used to hide initial error message when data is loading
    validate( need( expr = variables$variableName == input$variable &
                      variables$tableStub == user.table()
                      , message = "Loading. If no data loads, make sure you have selected a table and variable" ))

    
    #download data
    var <- variables$variableID[variables$variableName == input$variable &
                                variables$tableID == user.tableID()]
    
    level <- unique(variables$pop[variables$tableID == user.tableID()])

    acs <- acs::acs.fetch( geography = geog
                           , endyear = 2016
                           , span = 5
                           , variable = var 
                           , key = "90f2c983812307e03ba93d853cb345269222db13" )

    agg <- tractToCCA(acs = acs
                      , level = level)
    
    #also grab a total population estimate for this variable, to be used for calculating percent & per 100k outputs,
    #by downloading the Bxxxxx_001 variant of whatever table
    #Since we only need this when input$statToShow != "Total", let's only run it in those cases
    if(input$statToShow != "Total") {
    
      var.pop <- variables$variableID[variables$variableStub == input$denom
                                      & variables$tableID == user.tableID()]
      
      acs.pop <- acs::acs.fetch(geography = geog
                            , endyear = 2016
                            , span = 5
                            , variable = var.pop 
                            , key = "90f2c983812307e03ba93d853cb345269222db13" )
      
      agg.pop <- tractToCCA(acs = acs.pop 
                            , level = level)

    # tack on population estimate
    if(input$statToShow == "Percent") {
      
      #calculate estimate as percent
      agg$est <- agg$est / agg.pop$est
      
      #calculate margin of error as percent - see A-14 of https://www.census.gov/content/dam/Census/library/publications/2009/acs/ACSResearch.pdf
      agg$moe <- sqrt(agg$moe^2 - ((agg$est^2) * (agg.pop$moe^2))) / agg.pop$est
            
      agg <- dplyr::select(agg, CCA, est, moe)

    } else if(input$statToShow == "Per 100k") {
      
      #calculate estimate as percent
      agg$est <- agg$est / agg.pop$est
      
      #calculate margin of error as percent - see A-14 of https://www.census.gov/content/dam/Census/library/publications/2009/acs/ACSResearch.pdf
      agg$moe <- sqrt(agg$moe^2 - ((agg$est^2) * (agg.pop$moe^2))) / agg.pop$est
      
      #multiply both by 100,000
      agg$est <- agg$est * 100000
      agg$moe <- agg$moe * 100000
      
      agg <- dplyr::select(agg, CCA, est, moe)
    
    } else if(input$statToShow == "Per Individual Unit") {
      
      #calculate estimate as percent - this works the same as the "Percent" condition above
      agg$est <- agg$est / agg.pop$est
      
      #calculate margin of error as percent - see A-14 of https://www.census.gov/content/dam/Census/library/publications/2009/acs/ACSResearch.pdf
      agg$moe <- sqrt(agg$moe^2 - ((agg$est^2) * (agg.pop$moe^2))) / agg.pop$est
      
      agg <- dplyr::select(agg, CCA, est, moe)
      
    }
    
    }
 
    # return agg to the Global Environment
    return( agg )
    
  })
  
  # store fortified (tidy) data frame
  # that contains aggregated census tract statistics
  # for each CCA in a reactive expression
  fortified.data <- reactive({
    
    req(user.data())
    
    merge( x = CCAsF
           , y = user.data()
           , by = "CCA"
           , all = FALSE )
    
  })
  
  # store data frame
  # that contains census tract statistics
  # for each CCA in a reactive data frame
  cca.ct.data <- reactive({
    
    req(user.data())
    
    merge( x = CCAs
           , y = user.data()
           , by = "CCA"
           , all = FALSE )
    
  })
  
  # store data frame
  # that manipulates cca.ct.data() based on 
  # the slider input$nGeog
  # and rearranges the data based on the
  # users' interaction with the input$direction radio button
  bplot.data <- reactive({
 
    req(cca.ct.data(), input$direction, input$nGeog)
    
      switch( EXPR = input$direction
              , "Ascending" = cca.ct.data() %>%
                dplyr::arrange( est ) %>%
                dplyr::mutate( CCA = stats::reorder( x = CCA, X = est ) ) %>%
                head( n = input$nGeog )
              
              , "Descending" = cca.ct.data() %>% 
                dplyr::arrange( dplyr::desc( est ) ) %>%
                dplyr::mutate( CCA = stats::reorder( x = CCA, X = dplyr::desc( est ) ) ) %>%
                head( n = input$nGeog ) )
    
  })
  
  # set default map title
  output$maptitle <- renderUI({
    
    req(input$variable, user.table())
    
    default <- variables$plotTitle[variables$variableID == variables$variableID[variables$variableName == input$variable &
                                                                                  variables$tableStub == user.table()]]
    textInput("title.map", label = "Title", value = default)
    
  })
  
  # store map created from fortified.data()
  user.map <- reactive({
    
    req(fortified.data(), input$title.map, user.map.color(), input$statToShow)
    
    ggplot( data = fortified.data() ) +
      geom_polygon( aes(x = long, y = lat, group = group, fill = est)
                    , color = "#D2C2C2", size = .25) +
      coord_map() +
      ggtitle( label = input$title.map ) + 
      theme_void() +
      themeTitle +
      user.map.color() +
      labs( caption = "Source: ACS 2016 5 Year Estimates" )

  })
  

  # store barplot created from bplot.data()
  user.bplot <- reactive({
    
    req(bplot.data(), user.bplot.color(), user.moe.color(), input$variable)
    
    ggplot( data = bplot.data() ) +
      geom_bar( aes( x  = CCA
                     , y = est )
                , stat = "identity"
                , fill = user.bplot.color() ) +
      geom_errorbar( aes( x = CCA
                          , ymin = est - moe
                          , ymax = est + moe )
                     , color = user.moe.color()
                     , size = 1.25
                     , width = .5 ) +
      ggtitle( input$title.bar ) +
      theme( plot.title = element_text( hjust = 0.5, size = 20 ) ) +
      xlab( label = "Community Area" ) + 
      ylab( label = input$variable ) +
      themeMOE +
      scale_y_continuous( labels = user.labels() ) +
      labs( caption = "Source: ACS 2016 5 Year Estimates" )
  })
  
  # display user.map() in the UI
  output$map <- renderPlot({
    
    req(input$variable, user.table(), input$statToShow, input$title.map)
    # 
    # validate( need( expr = !is.null(input$variable) & !is.null(user.table()) & 
    #                   (input$statToShow == "Total" | (input$statToShow != "Total" & !is.null(input$denom)))
    #                 , message = "Data is loading. Please make sure to select a table, variable, and statistic." ))
    
    user.map()
    
  })
  
  # save the user.map()
  output$dwnld.map <- downloadHandler(
    filename = paste0( Sys.Date(), "-ACS_Map_Dashboard_map.png" )
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
    filename = paste0( Sys.Date(), "-ACS_Map_Dashboard_plot.png" )
    , content = function( file ){
      ggsave( filename = file
              , plot = user.bplot()
              , device = "png" )
    }
  )
  

  # transfrom user.data()
  # to be dislayed on a DataTable
  output$dwnld.table <- renderDataTable({

    table.data <- user.data()
    table.data[, c("est", "moe") ] <- round( x = table.data[, c("est", "moe") ], digits = user.digit() )
    table.data$moe <- paste0( "+/- ", table.data$moe )
    
    datatable( data = table.data
               , caption = "Table 1. 2016 5-Year ACS statistics by CCA"
               , colnames = c("CCA", input$variable, "90% Margin of Error" )
               , extensions = "Buttons"
               , rownames = FALSE
               , options = list( dom = "Blfrtip"
                                 , buttons = list( "csv" )
                                 , paging = FALSE ) ) 

  })
  
  # render text to identify
  # the universe documented in the ACS Table
  output$universe <- renderText({
    
    req(user.table())
    
    variables$universeStub[variables$tableStub == user.table()][1]

  })
  
  # create drop down menu
  # of tables to search; doing this here instead of ui.R because it should make the app faster in non-Chrome browsers
  output$otherTableOptions <- renderUI({
    
    selectizeInput( inputId = "selectTable"
                    , label = "Other tables (press backspace to enable searching):"
                    , choices = tableOptions )
    
  })
  
  # create drop down menu
  # of variables associated in the ACS Table
  output$variableOptions <- renderUI({

    req(user.tableID)
    
    variables <- variables$variableName[variables$tableID == user.tableID()]

    selectizeInput("variable", label = "Variable from Table", choices = variables)
        
  })
  
  # and of potential stats to choose
  output$statOptions <- renderUI ({
    
    req(input$variable)
    
    validate( need( expr = !is.null(input$variable) & !is.null(user.table())
                    , message = "Loading. If no data loads, make sure you have selected a table and variable" ))
    
    if(input$variable == "Total") {
      
      statOptions <- "Total"
      
    } else {
      
      statOptions <- c("Total", "Percent", "Per 100k", "Per Individual Unit")
      
    }

    selectInput("statToShow", "Statistic to Show:"
                , choices = statOptions
                , selected = "Total")

  })
  
  # and of potential denominators for each selected variable
  output$denomOptions <- renderUI ({
    
    req(user.tableID(), input$variable, input$statToShow)
    
    var <- variables[variables$variableName == input$variable &
                     variables$tableID == user.tableID(),]
    
    denomOptions <- c(var$parent0Stub,
                      var$parent1Stub,
                      var$parent2Stub,
                      var$parent3Stub,
                      var$parent4Stub,
                      var$parent5Stub)
    denomOptions <- denomOptions[!is.na(denomOptions)]
    
    selectInput( inputId = "denom"
                  , label = "Denominator:"
                  , choices = denomOptions
                  , selected = "Total:")
  
  })
    

  
  # set default barplot title
  output$bartitle <- renderUI({
    
    req(user.table())
    
    default <- variables$plotTitle[variables$variableID == variables$variableID[variables$variableName == input$variable &
                                                                                  variables$tableStub == user.table()]]
    
    textInput("title.bar", label = "Title", value = default)
    
  })
  
  
} # end of server

# end of script #