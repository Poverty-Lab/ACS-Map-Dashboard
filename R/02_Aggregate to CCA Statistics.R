######################################
##   City Data Graphics Dashboard   ##
##  2. Aggregate to CCA Statistics  ##
######################################


####  Startup  ####
rm(list = ls())
library( acs )
library( RCurl )

# create function to source scripts from GitHub
source_github <- function( url ) {
  # load package
  require(RCurl)
  
  # read script lines from website and evaluate
  script <- getURL(url, ssl.verifypeer = FALSE)
  eval(parse(text = script), envir=.GlobalEnv)
} 

## Source aggregation function
source_github( url = "https://raw.githubusercontent.com/Poverty-Lab/ACS-Map-Dashboard/master/R/00_Aggregation%20Function.R" )

## Load tract-level data
dfTract <- read.csv( file = "https://github.com/Poverty-Lab/ACS-Map-Dashboard/raw/master/Data/Tract%20Statistics.csv"
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
