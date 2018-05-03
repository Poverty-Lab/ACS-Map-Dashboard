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

source_github( url = "https://raw.githubusercontent.com/Poverty-Lab/ACS-Map-Dashboard/dev_ia/R/Aggregation_Function.R" )############FIX
source_github( url = "https://raw.githubusercontent.com/Poverty-Lab/ACS-Map-Dashboard/master/R/Themes.R")

####  Load data  ####
## Load CCA lists to append data onto
CCAs <- 
  read.csv( file = "https://raw.githubusercontent.com/Poverty-Lab/ACS-Map-Dashboard/master/Data/CCAs.csv"
            , header = TRUE
            , stringsAsFactors = FALSE )

CCAsF <- # a fortified version compatible with ggplot
  read.csv( file = "https://raw.githubusercontent.com/Poverty-Lab/ACS-Map-Dashboard/master/Data/CCAsF.csv"
            , header = TRUE
            , stringsAsFactors = FALSE )

#lists of census variables, tables, universes of data for each table
tableList <- read.csv(file = "https://raw.githubusercontent.com/Poverty-Lab/ACS-Map-Dashboard/master/Data/Census_tables.csv", stringsAsFactors = F) #table selection options
universeList <- read.csv(file = "https://raw.githubusercontent.com/Poverty-Lab/ACS-Map-Dashboard/master/Data/Census_universes.csv", stringsAsFactors = F) #universe label for that table
variableList <- read.csv(file = "https://raw.githubusercontent.com/Poverty-Lab/ACS-Map-Dashboard/master/Data/Census_variables.csv", stringsAsFactors = F) #variable selection options

#tract:CCA lookup
# load(file = "https://raw.githubusercontent.com/Poverty-Lab/ACS-Map-Dashboard/dev_ia/Data/Blocks_to_CCA_TR.rds") ##########FIX ######################
lookup <- 
  url( description = "https://github.com/Poverty-Lab/ACS-Map-Dashboard/blob/dev_ia/Data/Blocks_to_CCA_TR.rds" ) %>%
  gzcon() %>%
  readRDS()

# Set options for dataframes
tableOptions <- tableList$stub

statOptions <- c("Total", "Percent", "Per 100k")


####  Prime ACS Download Capabilities  ####
geog <- 
  url( description = "https://raw.github.com/Poverty-Lab/ACS-Map-Dashboard/dev_ia/Data/Cook_County_GeoSet.rds" ) %>%
  gzcon() %>%
  readRDS()

# allows the users to access API of the Census
acs::api.key.install( key = Sys.getenv( x = "CENSUS_KEY" ) )

# end of script #
