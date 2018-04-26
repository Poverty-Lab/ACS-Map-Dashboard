################################
##  Tract to CCA Aggregation  ##
##      1. Create Lookup      ##
################################


####  Setup  ####
library( dplyr )
library( rgdal )
library( rgeos )
library( sp )
rm(list = ls())


####  Load Data  ####
setwd( dir = "/export/code_library/R/UL_packages/acs_map_dashboard/Data/Shapefiles/" )

tracts <- readOGR( dsn = "Census Tracts (2010)/"
                   , layer = "tracts" )

blocks <- readOGR( dsn = "Census Blocks (2010)"
                   , layer = "blocks")

CCAs <-   readOGR( dsn = "CCAs"
                   , layer = "CCAs")


####  Create Tract to CCA Lookup  ####
  ## This will create a table that denotes for each census tract, the proportion of individuals and households within it that belong to X CCA.
  ## This allows users to aggregate up from census tract information to the CCA level in a way that is sensitive to tracts that overlap with multiple CCAs.
## Geospatially merge CCA and tract IDs onto census blocks
blocksCentroids <- rgeos::gCentroid(blocks, byid = T)
blocks@data$CCA <- sp::over(blocksCentroids, CCAs)$CCA
blocks@data$tractID <- sp::over(blocksCentroids, tracts)$tractID

## Aggregate data to CCA level, generating variables that show the percentage of each census tract (by population, households) that belongs to each CCA
lookup <- blocks@data %>%
  dplyr::group_by(tractID, CCA) %>%
  dplyr::summarise(blocks = n(),
                   pop = sum(pop),
                   HH = sum(HH)) %>%
  dplyr::filter(!is.na(tractID)) %>% #excluding blocks that do not belong to tracts in Cook County; including blocks that do not belong to CCAs but belong to tracts that will show up in Cook County data anyway
  dplyr::group_by(tractID) %>%
  dplyr::mutate(pctPop = pop / sum(pop), 
                pctHH = HH / sum(HH))


####  Compare with CMAP version  ####
## CMAP does something similar, and shared their lookup with us. However, theirs doesn't account for tracts that have some data outside of city boundaries 
## Load their lookup
setwd( dir = "/export/code_library/R/UL_packages/acs_map_dashboard/Data/" )

CMAP_lookup <- 
  read.csv( file = "Blocks_to_CCA_TR.csv"
            , header = TRUE
            , stringsAsFactors = FALSE )

CMAP_lookup <- CMAP_lookup %>%
  dplyr::group_by(TRACT, CCA) %>%
  dplyr::summarise(blocks = n(),
                   pctPop = sum(TR_POP_RAT),
                   pctHH = sum(TR_HH_RAT))

## Compare
print(CMAP_lookup[CMAP_lookup$pctPop > .1 & CMAP_lookup$pctPop < .9,]) #all CMAP major splits
print(lookup[lookup$pctPop > .1 & lookup$pctPop < .9,]) #all of our major splits
print(lookup[lookup$tractID %in% CMAP_lookup$TRACT[CMAP_lookup$pctPop > .1 & CMAP_lookup$pctPop < .9],]) #our versions of CMAP's major splits


####  Save  ####
write.csv( x = lookup
           , file = "Tract to CCA Aggregation Lookup.csv"
           , row.names = FALSE )

# end of script #
