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
library( RCurl )
library( scales )
library( shiny )


#FOR TESTING
#input <- c(); input$table = "Sex By Age"; input$variable = "Under 5 years (B01001_003)"; input$varType = "Count"; input$varPop = "Individual"; input$round = "Round"
#x = estimate(acs); tractID = acs@geography$tract; type = input$varType; level = input$varPop; return_df = T

####  Server  ####
server <- shinyServer(function(input, output, session) {
  
  # store user data
  # in a reactive expression
  user.data <- reactive({
    # require that the three inputs needed to fetch ACS data are not NULL
    # note: used to hide initial error message when data is loading
    validate( need( expr = variableList$stubLong == input$variable &
                        variableList$tableID == tableList$tableID[tableList$stub == input$table]
                      , message = "Loading. If no data loads, make sure you have selected a table and variable" )
              , need( expr = input$varType
                      , message = "Please specify this variable's type." )
              , need( expr = input$varPop
                       , message = "Please specify this variable's population." ) )
    
    #download data
    var <- variableList$variableID[variableList$stubLong == input$variable &
                                   variableList$tableID == tableList$tableID[tableList$stub == input$table]]

    acs <- acs::acs.fetch(geography = geog
                          , endyear = 2016
                          , span = 5
                          , variable = var )

    agg <- tractToCCA(acs = acs
                      , type = input$varType
                      , level = input$varPop)
    
    #also grab a total population estimate for this variable, to be used for calculating percent & per 100k outputs,
    #by downloading the Bxxxxx_001 variant of whatever table
    #Since we only need this when input$varType != "Total", let's only run it in those cases
    if(input$statToShow != "Total") {
    
    var.pop <- paste0(strsplit(var, "_")[[1]][1], "_001")
    acs.pop <- acs::acs.fetch(geography = geog
                          , endyear = 2016
                          , span = 5
                          , variable = var.pop )
    agg.pop <- tractToCCA(acs = acs.pop 
                          , type = input$varType
                          , level = input$varPop)

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
    
      }
    
    }

    if(tableList$medianFlag[tableList$stub == input$table] == T) {showNotification("You have selected a median, but medians cannot be aggregated up from tract to neighborhood", duration = NULL)}
 
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
                   , aes(x = long, y = lat, group = group, fill = est)
                   , color = NA, size = .25) +
      coord_map() +
      ggtitle(input$titleMap) + 
      themeTitle +
      themeMap
    
    if(input$varType %in% c("Count", "Mean")) {
      
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
        dplyr::arrange(desc(est)) %>%
        head(input$nGeog)
      

      bar <- ggplot() +
        geom_bar(aes(x = reorder(data$CCA, desc(eval(data$est))), y = data$est)
                 , stat = "identity", fill = "#8a0021") +
        geom_errorbar(aes(x = reorder(data$CCA, desc(eval(data$est))), ymin = data$est - data$moe, ymax = data$est + data$moe), color = "#f8a429", size = 1.25, width = .5) +
        ggtitle(input$titleBar) + theme(plot.title = element_text(hjust = 0.5, size = 20)) +
        scale_y_continuous(labels = comma) +
        xlab("Community Area") + ylab(variableList$stub[variableList$stubLong == input$variable]) +
        themeMOE
      
      if(input$varType %in% c("Count", "Mean")) {
        
        if(input$statToShow %in% c("Total", "Per 100k")) {
          
          bar <- bar + themeTot.100k_bar
          
        } else if(input$statToShow == "Percent") {
          
          bar <- bar + themePct_bar
          
        }
        
      }
      
      bar
      
    } else if(input$direction == "Ascending") {
      
      data <- 
        cca.ct.data() %>%
        dplyr::arrange(est) %>%
        head(input$nGeog)
      

      bar <- ggplot() +
        geom_bar(aes(x = reorder(data$CCA, eval(data$est)), y = data$est)
                 , stat = "identity", fill = "#8a0021") +
        geom_errorbar(aes(x = reorder(data$CCA, eval(data$est)), ymin = data$est - data$moe, ymax = data$est + data$moe), color = "#f8a429", size = 1.25, width = .5) +
        ggtitle(input$titleBar) + theme(plot.title = element_text(hjust = 0.5, size = 20)) +
        scale_y_continuous(labels = comma) +
        xlab("Community Area") + ylab(variableList$stub[variableList$stubLong == input$variable]) +
        themeMOE
      
      if(input$varType %in% c("Count", "Mean")) {
        
        if(input$statToShow %in% c("Total", "Per 100k")) {
          
          bar <- bar + themeTot.100k_bar
          
        } else if(input$statToShow == "Percent") {
          
          bar <- bar + themePct_bar
          
        }
        
      }
      
      bar
      
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
        
        if(input$statToShow %in% c("Total", "Per 100k")) {
          
          nDigits = 0
          
        } else if(input$statToShow == "Percent") {
          
          nDigits = 2
          
        }
        
      } else if(input$varType %in% c("Proportion", "Mean")) {
        
        nDigits = 2
        
      }
      
    } else if(input$round == "Don't Round") {
      
      nDigits = 12
      
    }
    
    data = user.data()
    data[,c(2,3)] <- round(data[,c(2,3)], digits = nDigits)
    data$moe <- paste0("+/- ", data$moe)
    
    # transfrom user.data()
    # to be dislayed on a DataTable
    datatable( data = data
               , caption = "Table 1. 2016 5-Year ACS statistics by CCA"
               , colnames = c("CCA", input$variable, "90% Margin of Error" )
               , extensions = "Buttons"
               , rownames = F
               , options = list( dom = "Blfrtip"
                                 , buttons = list( "csv" )
                                 , lengthMenu = list( c(15, 35, -1)
                                                      , c(15, 35, "All 77") )
                                 , pageLength = 15 ) ) 

  })

  output$instructions <- renderText("Press backspace to enable searching")
  
  output$universe <- renderText(universeList$stub[universeList$tableID == tableList$tableID[tableList$stub == input$table]])
  
  output$variableOptions <- renderUI({
    
    selectedTable <- tableList$tableID[tableList$stub == input$table]
    variables <- variableList$stubLong[variableList$tableID == selectedTable]

    selectizeInput("variable", label = "Variable from Table", choices = variables)
    
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
