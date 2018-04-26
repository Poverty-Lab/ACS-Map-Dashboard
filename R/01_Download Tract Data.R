####################################
##  City Data Graphics Dashboard  ##
##     1. Download Tract Data     ##
####################################


####  Startup  ####
rm(list = ls())
library(acs)


####  Variable Lookup  ####
#a function to help find new ones
#see also http://api.census.gov/data/2015/acs5/variables.html
lookup_vars <- function(x) {
  temp <- acs.lookup(endyear = 2015, table.name = x, case.sensitive = F)
  View(results(temp))
}

# load necessary data
setwd( dir = "/export/code_library/R/UL_packages/acs_map_dashboard/Data/" )

variables <- 
  read.csv( file = "Preselected Variables.csv"
            , header = TRUE
            , stringsAsFactors = FALSE )

####  ACS Package Prep  ####
# install API key - only once
# acs::api.key.install(key = Sys.getenv( x = "CENSUS_KEY" ) )

# set geographies
setwd( dir = "/export/code_library/R/UL_packages/acs_map_dashboard/Data/" )

geog <- geo.make( state = "IL", county = "Cook", tract = "*" )


####  Download Data  ####
#using variables spreadsheet, create first table that others will append to
acs <- acs::acs.fetch(geography = geog
                      , endyear = 2015
                      , span = 5
                      , variable = variables$ACS.Name[1]
                      , col.names = variables$App.Name[1] )

df <- data.frame(tractID = acs@geography$tract, 
                 estimate(acs), 
                 confint(acs, level = .9),
                 row.names = NULL )

#add all other tables
for(i in 2:length(variables$ACS.Name)) {
  
  print(paste0("variable = ", variables$Statistic[i], ", ", which(variables$ACS.Name == variables$ACS.Name[i]), " of ", length(variables$ACS.Name)))
  
  acsTemp <- acs::acs.fetch(geography = geog
                            , endyear = 2015
                            , span = 5
                            , variable = variables$ACS.Name[i]
                            , col.names = variables$App.Name[i] )

  
  dfTemp <- data.frame(tractID = acsTemp@geography$tract, 
                       estimate(acsTemp), 
                       confint(acsTemp, level = .9),
                       row.names = NULL)
  df <- merge(df, dfTemp)
}


####  Save  ####
write.csv( x = df
           , file = "Tract Statistics.csv"
           , row.names = FALSE )

# store geo.set object for future use when importing Cook County ACS data
saveRDS( object = geog
         , file = "Cook_County_GeoSet.rds" )

# end of script # 
