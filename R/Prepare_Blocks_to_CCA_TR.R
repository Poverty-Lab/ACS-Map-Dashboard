rm(list = ls())

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

## Reformat looku
#right now, each variable shows what proportion of each tract's population is found within a given block (e.g. 1%);
#we want it to say what proportion of each tract's population belongs to a given CCA (e.g. 0%, 50%, or 100%)
lookup <- lookup %>%
  dplyr::group_by(tractID, CCA) %>%
  dplyr::summarise(blocks = n(),
                   pctPop = sum(TR_POP_RAT),
                   pctHH = sum(TR_HH_RAT),
                   pctHU = sum(TR_HU_RAT))


####  Prepare totals  ####
##  Download and merge on total population, number of households, and number of household units
geog <- 
  url( description = "https://raw.github.com/Poverty-Lab/ACS-Map-Dashboard/master/Data/Cook_County_GeoSet.rds" ) %>%
  gzcon() %>%
  readRDS()

## Individuals
var.ind <- "B01003_001"
ind <- acs::acs.fetch(geography = geog
                      , endyear = 2015 # we should be using 2016 5-year ACS data
                      , span = 5
                      , variable = var.ind )

## Households
var.hh <- "B11016_001"
hh <- acs::acs.fetch(geography = geog
                      , endyear = 2015 # we should be using 2016 5-year ACS data
                      , span = 5
                      , variable = var.hh )

## Housing units
var.hu <- "B25001_001"
hu <- acs::acs.fetch(geography = geog
                      , endyear = 2015 # we should be using 2016 5-year ACS data
                      , span = 5
                      , variable = var.hu )


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

####  Save  ####
saveRDS(lookup, file = "Data/Blocks_to_CCA_TR.rds")