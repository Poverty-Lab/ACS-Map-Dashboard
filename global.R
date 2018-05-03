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
library( lettercase )

## Source aggregation function and plot themes
# create function to source scripts from GitHub
source_github <- function( url ) {
  # load package
  require(RCurl)
  
  # read script lines from website and evaluate
  script <- getURL(url, ssl.verifypeer = FALSE)
  eval(parse(text = script), envir=.GlobalEnv)
}

source_github( url = "https://raw.githubusercontent.com/Poverty-Lab/ACS-Map-Dashboard/master/R/Aggregation_Function.R" )
source_github( url = "https://raw.githubusercontent.com/Poverty-Lab/ACS-Map-Dashboard/master/R/Themes.R")

####  Load data  ####
## Load CCA lists to append data onto
CCAs <- 
  url( description = "https://github.com/Poverty-Lab/ACS-Map-Dashboard/blob/master/Data/CCAs.rds?raw=true" ) %>%
  gzcon() %>%
  readRDS()

CCAsF <-  # a fortified version compatible with ggplot
  url( description = "https://github.com/Poverty-Lab/ACS-Map-Dashboard/blob/master/Data/CCAsF.rds?raw=true" ) %>%
  gzcon() %>%
  readRDS()

#lists of census variables, tables, universes of data for each table
tableList <- 
  url( description = "https://github.com/Poverty-Lab/ACS-Map-Dashboard/blob/master/Data/Census_tables.rds?raw=true" ) %>%
  gzcon() %>%
  readRDS()

universeList <- 
  url( description = "https://github.com/Poverty-Lab/ACS-Map-Dashboard/blob/master/Data/Census_universes.rds?raw=true" ) %>%
  gzcon() %>%
  readRDS()

variableList <- 
  url( description = "https://github.com/Poverty-Lab/ACS-Map-Dashboard/blob/master/Data/Census_variables.rds?raw=true" ) %>%
  gzcon() %>%
  readRDS()

#tract:CCA lookup
lookup <- 
  url( description = "https://github.com/Poverty-Lab/ACS-Map-Dashboard/blob/master/Data/Blocks_to_CCA_TR.rds?raw=true" ) %>%
  gzcon() %>%
  readRDS()

#Set options for dataframes
tableOptions <- tableList$stub
statOptions <- c("Total", "Percent", "Per 100k")


####  Prime ACS Download Capabilities  ####
geog <- 
  url( description = "https://raw.github.com/Poverty-Lab/ACS-Map-Dashboard/master/Data/Cook_County_GeoSet.rds" ) %>%
  gzcon() %>%
  readRDS()

# allows the users to access API of the Census
acs::api.key.install( key = Sys.getenv( x = "CENSUS_KEY" ) )

# end of script #
