#
# Author:   Isaac Ahuvia and Cristian Nuno
# Date:     May 1, 2018
# Purpose:  Edit ACS 2016 table shells into a dataframe that can be used to populate the variable selection dropdown menu
#

####  Startup  ####

# clear global environment
rm( list = ls()) 

# load necessary packages
library(dplyr)
library(lettercase)
library(zoo)

# load necessary data
raw <- read.csv("https://raw.githubusercontent.com/Poverty-Lab/ACS-Map-Dashboard/master/Data/ACS2016_Table_Shells_With_Indexing.csv", stringsAsFactors = F)



####  Data Prep  ####
## Remove extraneous rows
raw <- raw[!raw$Table.ID %in% c("", " "),]

## Label which rows are table names and which are variable names
raw <- raw %>% dplyr::group_by(Table.ID) %>% dplyr::mutate(tableIndex = row_number())

raw$rowType <- "Variable Name" #default
raw$rowType[raw$tableIndex == 1] <- "Table Name"
raw$rowType[raw$tableIndex == 2] <- "Table Universe"

## Select, rename variables
raw <- dplyr::select(raw,
                     rowType,
                     tableID = Table.ID,
                     variableID = UniqueID,
                     stub = Stub,
                     indent = Index)

#stubs to Title Case
raw$stub <- lettercase::str_title_case(tolower(raw$stub))

## Delete certain rows
#filter to only loadable tables
raw <- raw[grepl(pattern = "B[0-9]{5}$", raw$tableID),]

#remove fake variables (have stubs but not actual data)
raw <- raw[!(raw$rowType == "Variable Name" & raw$variableID == ""),]


####  Reformat With One Variable per Row  ####
## Separate...
tables <- raw %>%
  dplyr::filter(rowType == "Table Name") %>%
  dplyr::select(tableID, variableID, stub)
variables <- raw %>%
  dplyr::filter(rowType == "Variable Name") %>%
  dplyr::select(tableID, variableID, stub, indent)
universes <- raw %>%
  dplyr::filter(rowType == "Table Universe") %>%
  dplyr::select(tableID, variableID, stub)

#rename certain variables
tables <- dplyr::rename(tables, tableStub = stub)
variables <- dplyr::rename(variables, variableStub = stub)
universes <- dplyr::rename(universes, universeStub = stub)

## ...and merge back properly formatted
variables <- merge(variables, tables, by = "tableID")
variables <- merge(variables, universes, by = "tableID")



####  Identify Parent Variables  ####
## A parent variable is a variable of the population a variable is a subpopulation of.
## Some variables have only one (e.g. "Total" is a parent variable of "Male" in B01001),
## while others have more than one (e.g. "Total" and "Male" are both parent variables of "Under 5 Years" in B01001).
## In these cases the highest-level parent is "Parent 1" and subsequent parents are "Parent 2," "Parent 3," etc.
variables <- dplyr::group_by(variables, tableID) %>% dplyr::mutate(indentMax = max(indent))

## A variable is a child if it is a subpopulation of a parent variable above it
## NOTE: A variable can be a child and not be the most indented variable in its table (see B02003, where "White Alone" is not a parent but is less indented than "White; Asian")
variables$childFlag <- variables$indent >= lag(variables$indent)
variables$parentFlag <- variables$indent < lead(variables$indent)
variables$parentFlag[nrow(variables)] <- F

variables$parentIndex <- NA
variables$parentIndex[variables$parentFlag == T] <- variables$indent[variables$parentFlag == T]


## Create new variables for each parent of a certain variable. Parent 0: highest-level parent
for(level in c(0,1,2,3,4,5)) {
  
  varname <- paste0("parent", level)
  varnameStub <- paste0("parent", level, "Stub")
  
  variables[[varname]] <- NA
  variables[[varname]][1] <- "temp"
  variables[[varname]][variables$indent == level & variables$parentFlag == T] <- variables$variableID[variables$indent == level & variables$parentFlag == T]
  variables[[varname]] <- zoo::na.locf(variables[[varname]])
  variables[[varname]][variables$indent <= level] <- NA
  
  variables[[varnameStub]] <- NA
  variables[[varnameStub]][1] <- "temp"
  variables[[varnameStub]][variables$indent == level & variables$parentFlag == T] <- variables$variableStub[variables$indent == level & variables$parentFlag == T]
  variables[[varnameStub]] <- zoo::na.locf(variables[[varnameStub]])
  variables[[varnameStub]][variables$indent <= level] <- NA
  
}



####  Produce User-friendly Variable Names  ####
## Including a variable name that includes parents, a default plot name
variables$variableName <- NA
variables$variableName[variables$indent %in% c(0, 1)] <- gsub(":", "", variables$variableStub[variables$indent %in% c(0, 1)])
variables$variableName[variables$indent >= 2] <- paste(variables$parent1Stub[variables$indent >= 2]
                                                       , variables$parent2Stub[variables$indent >= 2]
                                                       , variables$parent3Stub[variables$indent >= 2]
                                                       , variables$parent4Stub[variables$indent >= 2]
                                                       , variables$parent5Stub[variables$indent >= 2]
                                                       , variables$variableStub[variables$indent >= 2]
                                                       , sep = ": ")
variables$variableName <- gsub("NA: ", "", variables$variableName)
variables$variableName <- gsub("::", ":", variables$variableName)

#plot title
variables$plotTitle <- paste(variables$tableStub, variables$variableName, sep = " - ")



####  Classify, Filter Tables  ####
## Establish a flag variable to track tables to drop
variables$flag <- F

## Classify variable type: count, mean, median, or ratio
#default is count
variables$varType <- "Count"

#mean 
variables$varType[grepl("^Mean ", variables$tableStub)] <- "Mean"

#median
variables$varType[grepl("^Median ", variables$tableStub)] <- "Median"

#ratio
variables$varType[grepl("^Ratio ", variables$tableStub)] <- "Ratio"

## Filter by variable type: Only include counts
variables$flag[variables$varType != "Count"] <- T


## Classify variable population: individual, household, or household unit
#default is individual
variables$pop <- "Individual"

#pick out households
variables$pop[variables$universeStub %in% c("Universe: Households", "Universe:  Households", "Universe:  Nonfamily households", "Universe:  Total households")] <- "Household"

#pick out housing units
variables$pop[grepl("housing unit", variables$universeStub, ignore.case = T)] <- "Housing Unit"



####  Categorize Tables  ####
## For ease of selection, categorize tables into: housing, income, poverty, health, tenure



## Flag additional tables
#allocation variables (https://www.census.gov/programs-surveys/acs/methodology/sample-size-and-data-quality/item-allocation-rates-definitions.html)
variables$flag[grepl("allocat", variables$tableStub, ignore.case = T)] <- T

#Response rate information
variables$flag[grepl("response rate", variables$tableStub, ignore.case = T)] <- T

#coverage rate information
variables$flag[grepl("coverage rate", variables$tableStub, ignore.case = T)] <- T

#unweighted sample sizes
variables$flag[grepl("^Unweighted", variables$tableStub, ignore.case = T)] <- T


## Filter out flagged tables from each dataset
variables <- variables[variables$flag == F,]



####  Save  ####
saveRDS(variables, file = "Data/Census_variables.rds")

# end of script #
