rm(list = ls())

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


## Fix content
#right now, each variable shows what proportion of each tract's population is found within a given block (e.g. 1%);
#we want it to say what proportion of each tract's population belongs to a given CCA (e.g. 0%, 50%, or 100%)
lookup <- lookup %>%
  dplyr::group_by(tractID, CCA) %>%
  dplyr::summarise(blocks = n(),
                   pctPop = sum(TR_POP_RAT),
                   pctHH = sum(TR_HH_RAT))

## Save
saveRDS(lookup, file = "Data/Blocks_to_CCA_TR.rds")