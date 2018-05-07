#
# Author:   Cristian E. Nuno
# Date:  May 4, 2018
# Purpose:  Understand how to aggregate standard errors from ACS estimates
#

# clear global environment
rm( list = ls() )

# load necessary packages
library( acs )
library( bitops )
library( ggplot2 )
library( RCurl )


# create function to source scripts from GitHub
source_github <- function( url ) {
  # load package
  require(RCurl)
  
  # read script lines from website and evaluate
  script <- getURL(url, ssl.verifypeer = FALSE)
  eval(parse(text = script), envir=.GlobalEnv)
}

# source aggregation function
source_github( url = "https://raw.githubusercontent.com/Poverty-Lab/ACS-Map-Dashboard/master/R/Aggregation_Function.R" )

# load the pre-made CCA to CT lookup data frame
# note: this as close to a census tract to chicago community area crosswalk
#       that exists. Use data.frame( table( lookup$tractID ) ) to view
#       the census tracts that exist within multiple CCAs.
#       If a new source is found, this function will be updated.
# note: the object `lookup` will now exist in the Global Environment
lookup <- 
  url( description = "https://github.com/Poverty-Lab/ACS-Map-Dashboard/blob/master/Data/Blocks_to_CCA_TR.rds?raw=true" ) %>%
  gzcon() %>%
  readRDS()


# load API Census Key
api.key.install( key = Sys.getenv( x = "CENSUS_KEY" ) )

# load all Cook County, IL census tracts
geog <- geo.make( state = "IL", county = 31, tract = "*" )

# grab population estimates from 2015 5-year
pop.2015 <- acs.fetch( endyear = 2015
                       , span = 5
                       , geography = geog
                       , table.number = "B00001" )

# assign each tract a Chicago community area
agg.est <-
  tractToCCA( x = estimate( pop.2015 )
              , tractID = geography( pop.2015 )$tract
              , type = "Count"
              , level = "Individual"
              , return_df = TRUE )

## Reformat tract ID as necessary
## to ensure each value is an 11-digit string (FIPS Code)
## '17' for Illinois
## '031' for Cook County
## 'XXXXXX' 6 digits for the census tract
tractID <- as.character(geography( pop.2015 )$tract)
tractID[nchar(tractID) == 5] <- paste0("170310", tractID[nchar(tractID) == 5])
tractID[nchar(tractID) == 6] <- paste0("17031", tractID[nchar(tractID) == 6])

agg.std.err.manual <-
  merge( x = lookup
         , y = data.frame( tractID  = tractID
                           , StdErr = as.numeric(  standard.error( pop.2015 ) )
                           , stringsAsFactors = FALSE )
         , by = "tractID"
         , all = FALSE )

# calculate stnd err per CCA
agg.std.err.manual <-
  agg.std.err.manual %>%
  group_by( CCA ) %>%
  summarize( Agg_StdErr = sum( StdErr, na.rm = TRUE ) )

# now try with tractToCCA function
agg.std.err.automatic <-
  tractToCCA( x = standard.error( pop.2015 )
              , tractID = geography( pop.2015 )$tract
              , type = "Count"
              , level = "Individual"
              , return_df = TRUE )

# do the two methods produce identical results?
identical( x = agg.std.err.manual$Agg_StdErr
           , y = agg.std.err.automatic$x ) # [1] FALSE

# they don't. This is because tractToCCA() takes into 
# account the proportion of the population that resides
# in that particular census tract

# plot
bp <- 
  ggplot( data = agg.est
          , aes( x = CCA, y = x ) ) +
  geom_bar( stat = "identity", fill = "#800000" ) 

# add error bars
# and appropriate labels
bp +
  geom_errorbar( data = agg.std.err.automatic
                 , aes( x = CCA
                        , ymin = agg.est$x + x
                        , ymax = agg.est$x - x )
                 , col = "darkgoldenrod" ) +
  labs( title = "Using `tractToCCA()` to Calculate Aggregated Standard Errors"
        , caption = "Note: I don't believe this is correct"
        , ylab = "Population" ) +
  theme( axis.text.x = element_text( angle = 45, hjust = 1 ) )

# the results look suspect 
# are the error bars supposed to be this small?

# export results
setwd( dir = "/export/home/cenuno/ACS-Map-Dashboard/Visuals/" )

ggsave( filename = "Suspect_Errorbars.png"
        , plot = last_plot()
        , device = "png" )

# end of script #
