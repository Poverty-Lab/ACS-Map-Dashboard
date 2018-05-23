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

SourceGithub( url = "https://raw.githubusercontent.com/Poverty-Lab/ACS-Map-Dashboard/rename/R/Aggregation_Function.R" )
SourceGithub( url = "https://raw.githubusercontent.com/Poverty-Lab/ACS-Map-Dashboard/rename/R/Themes.R" )

####  Load data  ####
## Load CCA lists to append data onto
CCAs <- 
  url( description = "https://github.com/Poverty-Lab/ACS-Map-Dashboard/blob/rename/Data/CCAs.rds?raw=true" ) %>%
  gzcon() %>%
  readRDS()

CCAsF <-  # a fortified version compatible with ggplot
  url( description = "https://github.com/Poverty-Lab/ACS-Map-Dashboard/blob/rename/Data/CCAsF.rds?raw=true" ) %>%
  gzcon() %>%
  readRDS()

#list of census variables, tables
variables <- 
  url( description = "https://github.com/Poverty-Lab/ACS-Map-Dashboard/blob/rename/Data/Census_variables.rds?raw=true" ) %>%
  gzcon() %>%
  readRDS()

#tract:CCA lookup
lookup <- 
  url( description = "https://github.com/Poverty-Lab/ACS-Map-Dashboard/blob/rename/Data/Blocks_to_CCA_TR.rds?raw=true" ) %>%
  gzcon() %>%
  readRDS()

#Set options for dataframes
tableOptions <- variables$tableStub


####  Prime ACS Download Capabilities  ####
geog <- 
  url( description = "https://raw.github.com/Poverty-Lab/ACS-Map-Dashboard/rename/Data/Cook_County_GeoSet.rds" ) %>%
  gzcon() %>%
  readRDS()

# end of script #
