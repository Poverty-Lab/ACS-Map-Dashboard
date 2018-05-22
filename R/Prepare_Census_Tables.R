#
# Author:   Isaac Ahuvia and Cristian Nuno
# Date:     May 1, 2018
# Purpose:  Edit ACS 2016 table shells into a dataframe that can be used to populate the variable selection dropdown menu
#

####  Startup  ####

# clea global environment
rm( list = ls()) 

# load necessary packages
library(dplyr)
library(lettercase)

# load necessary data
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

## Filter to only loadable tables - IN FUTURE LET'S TRY TO MAKE MORE TABLES LOADABLE!
raw <- raw[grepl(pattern = "B[0-9]{5}$", raw$tableID),]

## Remove fake variables (have stubs but not actual data)
raw <- raw[!(raw$rowType == "Variable Name" & raw$variableID == ""),]

tableList <- raw[raw$rowType == "Table Name", c(2,4)]
variableList <- raw[raw$rowType == "Variable Name", 2:4]
universeList <- raw[raw$rowType == "Table Universe", c(2,4)]

## Add a flag for median variables, so we can produce a warning in the app (medians can't be aggregated)
tableList$medianFlag <- grepl("^MEDIAN", tableList$stub)

## Table stubs to title case
tableList$stub <- lettercase::str_title_case(tolower(tableList$stub))

## Variable IDs to stubs, so that all variables will show in the dropdown menu (even when there are two whose stubs would otherwise both be "Under 5" or something like that)
variableList$stubLong <- paste0(variableList$stub, " (", variableList$variableID, ")")



####  Classify, Filter Tables  ####
## Establish a flag variable to track tables to drop
tableList$flag <- F

## Classify variable type: count, mean, median, or ratio
#default is count
tableList$type <- "Count"

#mean 
tableList$type[grepl("^Mean ", tableList$stub)] <- "Mean"

#median
tableList$type[grepl("^Median ", tableList$stub)] <- "Median"

#ratio
tableList$type[grepl("^Ratio ", tableList$stub)] <- "Ratio"

## Filter by variable type: Only include counts
tableList$flag[tableList$type != "Count"] <- T


## Classify variable population: individual, household, or household unit
#default is individual
universeList$type <- "Individual"

#pick out households
universeList$type[universeList$stub %in% c("Universe: Households", "Universe:  Households", "Universe:  Nonfamily households", "Universe:  Total households")] <- "Household"

#pick out housing units
universeList$type[grepl("housing unit", universeList$stub, ignore.case = T)] <- "Housing Unit"



####  Categorize Tables  ####
## For ease of selection, categorize tables into: housing, income, poverty, health, tenure



## Flag additional tables
#allocation variables (https://www.census.gov/programs-surveys/acs/methodology/sample-size-and-data-quality/item-allocation-rates-definitions.html)
tableList$flag[grepl("allocat", tableList$stub, ignore.case = T)] <- T

#Response rate information
tableList$flag[grepl("response rate", tableList$stub, ignore.case = T)] <- T

#coverage rate information
tableList$flag[grepl("coverage rate", tableList$stub, ignore.case = T)] <- T

#unweighted sample sizes
tableList$flag[grepl("^Unweighted", tableList$stub, ignore.case = T)] <- T



## Filter out flagged tables from each dataset
drop <- tableList$tableID[tableList$flag == T]

tableList <- tableList[!tableList$tableID %in% drop,]
variableList <- variableList[!variableList$tableID %in% drop,]
universeList <- universeList[!universeList$tableID %in% drop,]



####  Save  ####
saveRDS(tableList, file = "Data/Census_tables.rds")
saveRDS(variableList, file = "Data/Census_variables.rds")
saveRDS(universeList, file = "Data/Census_universes.rds")

# end of script #
