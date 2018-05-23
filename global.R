#
# Author:   Isaac Ahuvia and Cristian Nuno
# Date:     May 1, 2018
# Purpose:  Create all global variables
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


## Source aggregation function and plot themes
# create function to source scripts from GitHub
SourceGithub <- function( url ) {
  # load package
  require(RCurl)
  
  # read script lines from website and evaluate
  script <- getURL(url, ssl.verifypeer = FALSE)
  eval(parse(text = script), envir=.GlobalEnv)
}

SourceGithub( url = "https://raw.githubusercontent.com/Poverty-Lab/ACS-Map-Dashboard/auto_vartypes/R/Aggregation_Function.R" )
SourceGithub( url = "https://raw.githubusercontent.com/Poverty-Lab/ACS-Map-Dashboard/auto_vartypes/R/Themes.R" )

####  Load data  ####
## Load CCA lists to append data onto
CCAs <- 
  url( description = "https://github.com/Poverty-Lab/ACS-Map-Dashboard/blob/auto_vartypes/Data/CCAs.rds?raw=true" ) %>%
  gzcon() %>%
  readRDS()

CCAsF <-  # a fortified version compatible with ggplot
  url( description = "https://github.com/Poverty-Lab/ACS-Map-Dashboard/blob/auto_vartypes/Data/CCAsF.rds?raw=true" ) %>%
  gzcon() %>%
  readRDS()

#lists of census variables, tables, universes of data for each table
tableList <- 
  url( description = "https://github.com/Poverty-Lab/ACS-Map-Dashboard/blob/auto_vartypes/Data/Census_tables.rds?raw=true" ) %>%
  gzcon() %>%
  readRDS()

universeList <- 
  url( description = "https://github.com/Poverty-Lab/ACS-Map-Dashboard/blob/auto_vartypes/Data/Census_universes.rds?raw=true" ) %>%
  gzcon() %>%
  readRDS()

variableList <- 
  url( description = "https://github.com/Poverty-Lab/ACS-Map-Dashboard/blob/auto_vartypes/Data/Census_variables.rds?raw=true" ) %>%
  gzcon() %>%
  readRDS()

#tract:CCA lookup
lookup <- 
  url( description = "https://github.com/Poverty-Lab/ACS-Map-Dashboard/blob/auto_vartypes/Data/Blocks_to_CCA_TR.rds?raw=true" ) %>%
  gzcon() %>%
  readRDS()

#Set options for dataframes
tableOptions <- tableList$stub


####  Prime ACS Download Capabilities  ####
geog <- 
  url( description = "https://raw.github.com/Poverty-Lab/ACS-Map-Dashboard/auto_vartypes/Data/Cook_County_GeoSet.rds" ) %>%
  gzcon() %>%
  readRDS()

# end of script #
