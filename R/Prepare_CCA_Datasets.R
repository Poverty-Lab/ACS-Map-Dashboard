library( dplyr )
library( magrittr )
library( ggplot2 )
library( rgdal )

rm(list = ls())

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

## Save
write.csv(CCAs, "Data/CCAs.csv", row.names = F)
write.csv(CCAsF, "Data/CCAsF.csv", row.names = F)