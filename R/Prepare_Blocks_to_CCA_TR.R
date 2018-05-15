#
# Author:   Isaac Ahuvia
# Date:     May 7, 2018
# Purpose:  Modify and Confirm Census Blocks for Census Tracts to Chicago Community Area aggregation
#

# Clear global environment
rm(list = ls())

# load necessary packages
library( acs )
library( dplyr )
library( lettercase )

####  Prepare lookup  ####
## Download block:CCA lookup
lookup <- read.csv( file = "https://raw.githubusercontent.com/Poverty-Lab/ACS-Map-Dashboard/master/Data/Blocks_to_CCA_TR.csv"
                    , header = TRUE
                    , stringsAsFactors = FALSE )

## Revise variables
lookup$BLOCK <- as.character(lookup$BLOCK)
lookup$TRACT <- as.character(lookup$TRACT)

lookup$CCA <- toupper(lookup$CCA)

lookup$CCA[lookup$CCA == "THE LOOP"] <- "LOOP"
lookup$CCA[lookup$CCA == "O'HARE"] <- "OHARE"

names(lookup)[1:2] <- c("blockID", "tractID")

## Reformat lookup
## right now, each variable shows what proportion of each tract's population is found within a given block (e.g. 1%);
## we want it to say what proportion of each tract's population belongs to a given CCA (e.g. 0%, 50%, or 100%)
lookup <- lookup %>%
  dplyr::group_by(tractID, CCA) %>%
  dplyr::summarise(blocks = n(),
                   pct.ind = sum(TR_POP_RAT),
                   pct.hh = sum(TR_HH_RAT),
                   pct.hu = sum(TR_HU_RAT))


####  Prepare totals  ####
##  Download and merge on total population, number of households, and number of household units
geog <- 
  url( description = "https://raw.github.com/Poverty-Lab/ACS-Map-Dashboard/master/Data/Cook_County_GeoSet.rds" ) %>%
  gzcon() %>%
  readRDS()

## Individuals
var.ind <- "B01003_001"
ind <- acs::acs.fetch( geography = geog
                      , endyear = 2016
                      , span = 5
                      , variable = var.ind
                      , key = "90f2c983812307e03ba93d853cb345269222db13" )

## Households
var.hh <- "B11016_001"
hh <- acs::acs.fetch( geography = geog
                     , endyear = 2016
                     , span = 5
                     , variable = var.hh
                     , key = "90f2c983812307e03ba93d853cb345269222db13" )

## Housing units
var.hu <- "B25001_001"
hu <- acs::acs.fetch( geography = geog
                     , endyear = 2016
                     , span = 5
                     , variable = var.hu
                     , key = "90f2c983812307e03ba93d853cb345269222db13" )


####  Merge on totals  ####
## Prepare for merge
#confirm we can just bind these datasets together without doing a merge
all(hh@geography$tract == hu@geography$tract & hh@geography$tract == ind@geography$tract)

totals <- data.frame(tractID = ind@geography$tract,
                     ind = ind@estimate,
                     hh = hh@estimate,
                     hu = hu@estimate)

totals$tractID <- as.character(totals$tractID)
totals$tractID[nchar(totals$tractID) == 5] <- paste0("170310", totals$tractID[nchar(totals$tractID) == 5])
totals$tractID[nchar(totals$tractID) == 6] <- paste0("17031", totals$tractID[nchar(totals$tractID) == 6])

## Merge
lookup <- merge(lookup, totals, by = "tractID")

#rename
lookup <- dplyr::rename(lookup,
                        tot.ind = B01003_001,
                        tot.hh = B11016_001,
                        tot.hu = B25001_001)

## Finally, adjust the totals so that they are split up when a tract is shared across CCAs (with before/after checks)
lookup[lookup$tractID == "17031081403",]
sum(lookup$tot.ind)

lookup$tot.ind <- lookup$tot.ind * lookup$pct.ind
lookup$tot.hh <- lookup$tot.hh * lookup$pct.hh
lookup$tot.hu <- lookup$tot.hu * lookup$pct.hu

lookup[lookup$tractID == "17031081403",]
sum(lookup$tot.ind)

## CCA name to Title Case
lookup$CCA <- lettercase::str_title_case(tolower(lookup$CCA))

####  Save  ####
saveRDS(lookup, file = "Data/Blocks_to_CCA_TR.rds")

# end of script #
