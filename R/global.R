#
# Author:   Isaac Ahuvia and Cristian Nuno
# Date:     Aril 26, 2018
# Purpose:  Define objects to be used globablly within the ui.R and server.R scripts
#

# load necessary packages
rm(list = ls())
library(dplyr)
library(shiny)
library(shinyjs)
library(ggplot2)
library(scales)
library(shinyBS)
library(shinythemes)
library(dygraphs)
library(plotly)
library(DT)
library(shinydashboard)
library(grDevices)
library(acs)

# load necessary themes & functions
setwd( dir = "/export/code_library/R/UL_packages/acs_map_dashboard/R/" )

source( file = "00_Themes.R" )
source( file = "00_Aggregation Function.R" )

# load necessary data
setwd( dir = "/export/code_library/R/UL_packages/acs_map_dashboard/Data/" )

variables <- 
  read.csv( file = "Preselected Variables.csv"
            , header = TRUE
            , stringsAsFactors = FALSE )
CCA <- 
  read.csv( file = "CCA Statistics.csv"
            , header = TRUE
            , stringsAsFactors = FALSE )

load( file = "CCA Statistics Fortified.RData" )

# Set options for preset dataframes
contentOptions <- paste0( variables$Population
                         , " - "
                         , variables$Statistic ) # add headers from variables$category 
statOptions <- c("Total", "Percent", "Per 100k")
# geogOptions <- c("CCA"
#                  , "Census Tract"
#                  , "ZIP"
#                  , "Heatmap") # make reactive such that only those available for each content option show (or others are greyed out)





# end of script #
