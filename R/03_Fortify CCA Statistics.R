####################################
##  City Data Graphics Dashboard  ##
##   3. Fortify CCA Statistics    ##
####################################


####  Startup  ####
rm(list = ls())
library(ggplot2)
library(rgdal)

## Load tract-level data
setwd( dir = "/export/code_library/R/UL_packages/acs_map_dashboard/Data/" )

dfCCA <- read.csv( file = "CCA Statistics.csv"
                  , header = TRUE
                  , stringsAsFactors = FALSE )

## Load CCA map (unfortified)
CCAs_Shape <- readOGR( dsn = "Shapefiles/CCAs/"
                       , layer = "CCAs"
                       , stringsAsFactors = FALSE )


####  Fortify  ####
## Fortify to get shapefile into a format that can be read by ggplot
dfCCAF <- ggplot2::fortify(CCAs_Shape, region = "CCA")
names(dfCCAF)[names(dfCCAF) == "id"] <- "CCA"

## Merge to add statistics 
dfCCAF <- merge(dfCCAF, dfCCA, by = "CCA", sort = F)


####  Save  ####
save( dfCCAF
      , file = "CCA Statistics Fortified.RData"
      , row.names = FALSE )

# end of script #
