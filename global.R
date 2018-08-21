#
# Author:   Isaac Ahuvia and Cristian Nuno
# Date:     August 21, 2018
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
sourceGithub <- function( url ) {
  
  # load package
  require(RCurl)
  
  # read script lines from website and evaluate
  script <- getURL(url, ssl.verifypeer = FALSE)
  eval(parse(text = script), envir=.GlobalEnv)
  
}

sourceGithub( url = "https://raw.githubusercontent.com/Poverty-Lab/ACS-Map-Dashboard/master/R/Aggregation_Function.R" )
sourceGithub( url = "https://raw.githubusercontent.com/Poverty-Lab/ACS-Map-Dashboard/master/R/Themes.R" )

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

#list of census variables, tables
variables <- 
  url( description = "https://github.com/Poverty-Lab/ACS-Map-Dashboard/blob/master/Data/Census_variables.rds?raw=true" ) %>%
  gzcon() %>%
  readRDS()

#tract:CCA lookup
lookup <- 
  url( description = "https://github.com/Poverty-Lab/ACS-Map-Dashboard/blob/master/Data/Blocks_to_CCA_TR.rds?raw=true" ) %>%
  gzcon() %>%
  readRDS()

#Set options for dataframes
tableOptions <- variables$tableStub

tableOptionsSlim <- list(
  
  "Demographics" = c("Total Population",
                     "Sex By Age",
                     "Race",
                     "Hispanic Or Latino Origin",
                     "Nativity And Citizenship Status In The United States",
                     "Geographical Mobility In The Past Year By Age For Current Residence In The United States"),
  
  "Home" = c("Tenure",
             "Own Children Under 18 Years By Family Type And Age",
             "Household Type (Including Living Alone) By Relationship ",
             "Language Spoken At Home By Ability To Speak English For The Population 5 Years And Over (Hispanic Or Latino)"),  
  
  "Labor Market" = c("Poverty Status In The Past 12 Months By Sex By Age",
                     "Earnings In The Past 12 Months For Households",
                     "Employment Status For The Population 16 Years And Over",
                     "Means Of Transportation To Work"),

  "Education" = c("School Enrollment By Level Of School For The Population 3 Years And Over",
                  "Educational Attainment For The Population 25 Years And Over"),
             
  "Health" = c("Types Of Health Insurance Coverage By Age",
               "Sex By Age By Disability Status"),
  
  "Other"
  
)

####  Prime ACS Download Capabilities  ####
geog <- 
  url( description = "https://raw.github.com/Poverty-Lab/ACS-Map-Dashboard/master/Data/Cook_County_GeoSet.rds" ) %>%
  gzcon() %>%
  readRDS()

# end of script #