######################################
##   City Data Graphics Dashboard   ##
##  2. Aggregate to CCA Statistics  ##
######################################


####  Startup  ####
rm(list = ls())
library(acs)

## Source aggregation function
setwd( dir = "/export/code_library/R/UL_packages/acs_map_dashboard/R/" )

source( file = "00_Aggregation Function.R" )

## Load tract-level data
setwd( dir = "/export/code_library/R/UL_packages/acs_map_dashboard/Data/" )

dfTract <- read.csv( file = "Tract Statistics.csv"
                    , header = TRUE
                    , stringsAsFactors = FALSE )



####  Aggregate  ####
temp <- tractToCCA(x = dfTract$Ind.Count.Total
                   , tractID = dfTract$tractID
                   , type = "Count"
                   , level = "Individual" )

dfCCA <- data.frame(CCA = names(temp),
                    Ind.Count.Total = temp,
                    stringsAsFactors = FALSE )

for(var in names(dfTract[,2:length(dfTract)])) {
  
  dfCCA[[var]] <- tractToCCA(x = dfTract[[var]]
                             , tractID = dfTract$tractID
                             , type = "Count"
                             , level = "Individual" )
  
}


####  Save  ####
write.csv( x = dfCCA
           , file = "CCA Statistics.csv"
           , row.names = FALSE )

# end of script #
