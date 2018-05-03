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

## Save
saveRDS(lookup, file = "Data/Blocks_to_CCA_TR.rds")