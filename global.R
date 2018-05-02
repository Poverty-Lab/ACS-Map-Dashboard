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
## Load prepared datasets (data prep is done outside of app)
#for table, barplot
CCA <- 
  read.csv( file = "https://raw.githubusercontent.com/Poverty-Lab/ACS-Map-Dashboard/master/Data/CCA%20Statistics.csv"
            , header = TRUE
            , stringsAsFactors = FALSE )

#for map (this is a fortified dataset compatible with ggplot)
dfCCAF <-
  url( description = "https://github.com/Poverty-Lab/ACS-Map-Dashboard/raw/master/Data/CCA%20Statistics%20Fortified.rds" ) %>%
  gzcon() %>%
  readRDS()

tableList <- read.csv(file = "https://raw.githubusercontent.com/Poverty-Lab/ACS-Map-Dashboard/master/Data/Variable%20selection_tables.csv", stringsAsFactors = F) #table selection options
universeList <- read.csv(file = "https://raw.githubusercontent.com/Poverty-Lab/ACS-Map-Dashboard/master/Data/Variable%20selection_universes.csv", stringsAsFactors = F) #universe label for that table
variableList <- read.csv(file = "https://raw.githubusercontent.com/Poverty-Lab/ACS-Map-Dashboard/master/Data/Variable%20selection_variables.csv", stringsAsFactors = F) #variable selection options

# Set options for dataframes
tableOptions <- tableList$stub

statOptions <- c("Total", "Percent", "Per 100k")


####  Prime ACS Download Capabilities  ####
geog <- 
  url( description = "https://github.com/Poverty-Lab/ACS-Map-Dashboard/raw/master/Data/Cook_County_GeoSet.rds" ) %>%
  gzcon() %>%
  readRDS()

# end of script #
