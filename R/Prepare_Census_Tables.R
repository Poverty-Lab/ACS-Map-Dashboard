#
# Author:   Isaac Ahuvia and Cristian Nuno
# Date:     May 1, 2018
# Purpose:  Edit ACS 2016 table shells into a dataframe that can be used to populate the variable selection dropdown menu
#

####  Startup  ####
library(dplyr)

raw <- read.csv("https://raw.githubusercontent.com/Poverty-Lab/ACS-Map-Dashboard/master/Data/ACS2016_Table_Shells.csv", stringsAsFactors = F)


####  Data Prep  ####
## Remove extraneous rows
raw <- raw[2:nrow(raw),]
raw <- raw[!raw$Table.ID %in% c("", " "),]

## Label which rows are table names and which are variable names
raw <- raw %>% dplyr::group_by(Table.ID) %>% dplyr::mutate(tableIndex = row_number())

raw$rowType <- NA
raw$rowType[raw$tableIndex == 1] <- "Table Name"
raw$rowType[raw$tableIndex == 2] <- "Table Universe"
raw$rowType[!raw$tableIndex %in% c(1,2)] <- "Variable Name"

## Select, rename variables
raw <- dplyr::select(raw,
                     rowType,
                     tableID = Table.ID,
                     variableID = UniqueID,
                     stub = Stub)

tableList <- raw[raw$rowType == "Table Name", c(2,4)]
variableList <- raw[raw$rowType == "Variable Name", 2:4]
universeList <- raw[raw$rowType == "Table Universe", c(2,4)]


####  Save  ####
write.csv(tableList, file = "Data/Census_tables.csv", row.names = F)
write.csv(variableList, file = "Data/Census_variables.csv", row.names = F)
write.csv(universeList, file = "Data/Census_universes.csv", row.names = F)
