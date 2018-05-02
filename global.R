#
# Author:   Isaac Ahuvia and Cristian Nuno
# Date:     May 1, 2018
# Purpose:  Create all global variables
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

## Source aggregation function and plot themes
# create function to source scripts from GitHub
source_github <- function( url ) {
  # load package
  require(RCurl)
  
  # read script lines from website and evaluate
  script <- getURL(url, ssl.verifypeer = FALSE)
  eval(parse(text = script), envir=.GlobalEnv)
}

source_github( url = "https://raw.githubusercontent.com/Poverty-Lab/ACS-Map-Dashboard/master/R/00_Aggregation%20Function.R" )
source_github( url = "https://raw.githubusercontent.com/Poverty-Lab/ACS-Map-Dashboard/master/R/00_Themes.R")

####  Load data  ####
## Load prepared datasets (do data prep outside of app)
variables <- 
  read.csv( file = "https://raw.githubusercontent.com/Poverty-Lab/ACS-Map-Dashboard/master/Data/Preselected%20Variables.csv"
            , header = TRUE
            , stringsAsFactors = FALSE )
CCA <- 
  read.csv( file = "https://raw.githubusercontent.com/Poverty-Lab/ACS-Map-Dashboard/master/Data/CCA%20Statistics.csv"
            , header = TRUE
            , stringsAsFactors = FALSE )

dfCCAF <-
  url( description = "https://github.com/Poverty-Lab/ACS-Map-Dashboard/raw/master/Data/CCA%20Statistics%20Fortified.rds" ) %>%
  gzcon() %>%
  readRDS()

tableList <- read.csv(file = "https://raw.githubusercontent.com/Poverty-Lab/ACS-Map-Dashboard/master/Data/Variable%20selection_tables.csv", stringsAsFactors = F) #table selection options
universeList <- read.csv(file = "https://raw.githubusercontent.com/Poverty-Lab/ACS-Map-Dashboard/master/Data/Variable%20selection_universes.csv", stringsAsFactors = F) #universe label for that table
variableList <- read.csv(file = "https://raw.githubusercontent.com/Poverty-Lab/ACS-Map-Dashboard/master/Data/Variable%20selection_variables.csv", stringsAsFactors = F) #variable selection options

# Set options for preset dataframes
tableOptions <- tableList$stub


contentOptions <- paste0( variables$Population
                          , " - "
                          , variables$Statistic ) # add headers from variables$category 

statOptions <- c("Total", "Percent", "Per 100k")

#geogOptions <- c("CCA", "Census Tract", "ZIP", "Heatmap") #make reactive such that only those available for each content option show (or others are greyed out)


####  Prime ACS Download Capabilities  ####
geog <- 
  url( description = "https://github.com/Poverty-Lab/ACS-Map-Dashboard/raw/master/Data/Cook_County_GeoSet.rds" ) %>%
  gzcon() %>%
  readRDS()

# end of script #
