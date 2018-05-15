#
# Author:   Isaac Ahuvia & Cristian Nuno
# Date:     May 7, 2018
# Purpose:  Fortify CCA shapefile so that it may added as a geom for future ggplot style plots
#

# clean global environment
rm(list = ls())

# load necssary packages
library( dplyr )
library( ggplot2 )
library( lettercase )

## Load
CCAs_Shape <- 
  url( description = "https://github.com/Poverty-Lab/ACS-Map-Dashboard/raw/master/Data/Shapefiles/CCAs/CCAs.rds" ) %>%
  gzcon() %>%
  readRDS()

## Build datasets
CCAs <- data.frame(CCA = CCAs_Shape@data$CCA,
                   CCANum = CCAs_Shape@data$CCANum,
                   stringsAsFactors = F)

CCAsF <- ggplot2::fortify( model = CCAs_Shape )
#add CCA names back on. This is a little funky, as the fortified object doesn't currently have any labels for each polygon beyond an "id" variable that simply starts at zero and goes up for each polygon
lookup <- data.frame(id = as.character(seq(0, 76)),
                     CCA = CCAs$CCA,
                     CCANum = CCAs$CCANum,
                     stringsAsFactors = F)
CCAsF <- merge(CCAsF, lookup, by = "id")

## Change CCA names to Title Case
CCAs$CCA <- lettercase::str_title_case(tolower(CCAs$CCA))
CCAsF$CCA <- lettercase::str_title_case(tolower(CCAsF$CCA))

## Save
saveRDS(CCAs, "Data/CCAs.rds")
saveRDS(CCAsF, "Data/CCAsF.rds")

# end of script #
