#######################################
##      Tract to CCA Aggregation     ##
##      2. Aggregation Function      ##
#######################################

####  Aggregate Function  ####
tractToCCA <- function(acs
                       , est = NULL
                       , se = NULL
                       , tractID = NULL
                       , level = c("Individual", "Household", "Housing Unit")) {
  
  ####  Readme  ####
  #acs: An ACS object from which to draw the estimate in question, its standard error, and the tractIDs for each value
  #est: A vector of estimates to aggregate. If you supply an acs object, est will automatically populate from that.
  #se: A vector of standard errors to aggregate. If you supply an acs object, se will automatically populate from that.
  #tractID: A vector of tract IDs to aggregate. If you supply an acs object, tractID will automatically populate from that.
  #level: The level of analysis. Individual or household.
  
  
  
  ####  Setup  ####
  ## Package requirements
  require( dplyr )
  
  
  ## Requirements
  if(!is.null(acs) & (!is.null(est) | !is.null(se) | !is.null(tractID))) {
    warning("'acs' is not null; 'est', 'se', and 'tractID' will be calculated from this object and overwritten")
  }
  
  if(is.null(acs) & (is.null(est) | is.null(se) | is.null(tractID))) {
    stop("must supply either 'acs' or all of 'est', 'se', and 'tractID'")
  }
  
  if(is.null(acs) & (length(est) != length(se) | length(est) != length(tractID))) {
    stop("'est', 'se', and 'tractID' must be of the same length")
  }
  
  if(!level %in% c("Individual", "Household", "Housing Unit")) {
    stop("level must be one of Individual, Household, Housing Unit")
  }
  
  
  ## If supplied acs, break down into est, se, and tractID
  if(!is.null(acs)) {
    
    est <- acs::estimate(acs)
    se <- acs::standard.error(acs)
    tractID <- acs::geography(acs)$tract
    
  }
  
  
  ####  Merge Inputs  ####
  ## Reformat tract ID as necessary
  #to ensure each value is an 11-digit string (FIPS Code)
  #'17' for Illinois
  #'031' for Cook County
  #'XXXXXX' 6 digits for the census tract
  tractID <- as.character(tractID)
  tractID[nchar(tractID) == 5] <- paste0("170310", tractID[nchar(tractID) == 5])
  tractID[nchar(tractID) == 6] <- paste0("17031", tractID[nchar(tractID) == 6])
  
  
  ## Merge inputs to lookup dataframe for aggregation
  inputs <- data.frame(tractID = as.character(tractID),
                       est = as.numeric(est),
                       se = as.numeric(se),
                       stringsAsFactors = F)
  df <- merge(lookup, inputs, by = "tractID")
  
  
  
  ####  Aggregate Estimate  ####
  if(level == "Individual") {
    df$tot <- df$tot.ind
    df$pct <- df$pct.ind
  } else if(level == "Household") {
    df$tot <- df$tot.hh
    df$pct <- df$pct.hh
  } else if(level == "Housing Unit") {
    df$tot <- df$tot.hu
    df$pct <- df$pct.hu
  }
  
  
  ## Aggregate
  df.aggEst <- df %>%
    dplyr::mutate(est = est * pct) %>% #calculate estimate, split by tract:CCA pair (e.g. males per tract:CCA pair)
    dplyr::group_by(CCA) %>%
    dplyr::summarise(est = sum(est, na.rm = T)) %>% #calculate estimate, totalled for each CCA (e.g. males per CCA)
    dplyr::filter(!is.na(CCA)) %>%
    dplyr::select(CCA, est)

  
  
  
  ####  Aggregate Standard Errors  ####
  
  #for aggregation math, see page A-14 in https://www.census.gov/content/dam/Census/library/publications/2009/acs/ACSResearch.pdf
  
  #for tracts with a split of 90/10 or more severe, just assign all error to the CCA that includes >90% of the tract's population
  #otherwise, we assign the standard error to both CCAs (this is the most conservative way to estimate the new standard error)
  #we're only splitting these by more than 10% df[which(df$pct.ind > .1 & df$pct.ind < .9),]
  df$pct.ind[df$pct.ind >= .9] <- 1
  df <- df[!df$pct.ind < .1,]
  
  df.aggSE <- df %>%
    dplyr::mutate(moe = se * 1.645) %>% #calculate 90% margin of error from standard error
    dplyr::mutate(moe.sq = moe ^ 2) %>% #sqare margin of error
    dplyr::group_by(CCA) %>%
    dplyr::summarise(moe = sqrt(sum(moe.sq))) %>% #take root of sum of squares
    dplyr::filter(!is.na(CCA)) %>%
    dplyr::select(CCA, moe)

  
  ## For later...
  #Aggregating medians:  http://www.dof.ca.gov/Forecasting/Demographics/Census_Data_Center_Network/documents/How_to_Recalculate_a_Median.pdf
  #See also https://en.wikipedia.org/wiki/Pareto_interpolation
  
  df.out <- merge(df.aggEst, df.aggSE, by = "CCA")
  
  ####  Return  ####
  return(df.out)
  
}

# end of script #
