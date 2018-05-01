####################################
##  City Data Graphics Dashboard  ##
##   3. Fortify CCA Statistics    ##
####################################


####  Startup  ####
rm(list = ls())
library( magrittr )
library( ggplot2 )
library( rgdal )

## Load tract-level data
dfCCA <- read.csv( file = "https://raw.githubusercontent.com/Poverty-Lab/ACS-Map-Dashboard/master/Data/CCA%20Statistics.csv"
                  , header = TRUE
                  , stringsAsFactors = FALSE )

## Load CCA map (unfortified)
CCAs_Shape <- 
  url( description = "https://github.com/Poverty-Lab/ACS-Map-Dashboard/raw/master/Data/Shapefiles/CCAs/CCAs.rds" ) %>%
  gzcon() %>%
  readRDS()


####  Fortify  ####
## Fortify to get shapefile into a format that can be read by ggplot
## note: broom::tidy() is now recommended
##       however, both ggplot2::fortify() and its broom equivalent
#        cause fatal errors when the `region` argument is specified
dfCCAF <- ggplot2::fortify( model = CCAs_Shape )
names(dfCCAF)[names(dfCCAF) == "id"] <- "CCA"

## Merge to add statistics 
dfCCAF <- merge(dfCCAF, dfCCA, by = "CCA", sort = F)


####  Save  ####
save( dfCCAF
      , file = "CCA Statistics Fortified.RData"
      , row.names = FALSE )

# end of script #
