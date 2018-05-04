#######################################
##      Tract to CCA Aggregation     ##
##      2. Aggregation Function      ##
#######################################


####  Setup  ####
library(dplyr)

####  Aggregate Function  ####
tractToCCA <- function(x, tractID
                       , type = c("Count", "Proportion", "Mean")
                       , level = c("Individual", "Household", "Housing Unit")
                       , transformation = NA, return_df = FALSE ) {
  
  #x: The statistic to aggregate. A vector of the same length as tractID.
  #tractID: A vector of tract IDs to aggregate. 
  #type: The type of statistic to aggregate. Count, proportion, or ratio.
  #level: The level of analysis. Individual or household.
  #transformation: If you want to take a count and turn it into a proportion by CCA (not really sure how to do this - will have to ID pop variables for each var) 
  #return_df: If TRUE, returns df with CCA & statistic, otherwise a named vector of the statistic.
  
  ## Requirements
  if(!length(x) > 1 & length(x) == length(tractID)) {
    stop("x must be a vector corresponding to statistics for each tract; x and tractID must be the same length")
  }
  if(!length(tractID) > 1 & length(x) == length(tractID)) {
    stop("tractID must be a vector corresponding to each tract; x and tractID must be the same length")
  }
  if(!type %in% c("Count", "Proportion", "Mean")) {
    stop("type must be one of Count, Proportion, or Mean")
  }
  if(!level %in% c("Individual", "Household", "Housing Unit")) {
    stop("level must be one of Individual, Household")
  }
  
  
  ## Reformat tract ID as necessary
  tractID <- as.character(tractID)
  tractID[nchar(tractID) == 5] <- paste0("170310", tractID[nchar(tractID) == 5])
  tractID[nchar(tractID) == 6] <- paste0("17031", tractID[nchar(tractID) == 6])
  
  
  ## Merge inputs to lookup dataframe for aggregation
  inputs <- data.frame(tractID = as.character(tractID),
                       x = as.numeric(x),
                       stringsAsFactors = F)
  df <- merge(lookup, inputs, by = "tractID")
  
  
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
  if(type == "Count") {
    
    dfOut <- df %>%
      dplyr::mutate(x.Count = x * pct) %>% #calculate total income for each tract-CCA pairing
      dplyr::group_by(CCA) %>%
      dplyr::summarise(x = sum(x.Count, na.rm = T)) %>% #returns a count
      dplyr::filter(!is.na(CCA))
    
  } else if(type == "Proportion") {
    
    dfOut <- df %>%
      dplyr::mutate(x.Count = x * tot) %>% #calculate total income for each tract-CCA pairing              ######### WHAT TO DO ABOUT MOE?
      dplyr::group_by(CCA) %>%
      dplyr::summarise(x.Count = sum(x.Count, na.rm = T),
                       tot = sum(tot, na.rm = T)) %>%
      dplyr::mutate(x = x.Count / tot) %>% #returns a proportion
      dplyr::filter(!is.na(CCA))
    
  } else if(type == "Mean") {
    
    dfOut <- df %>%
      dplyr::mutate(x.Count = x * tot) %>% #calculate total income for each tract-CCA pairing              ######### WHAT TO DO ABOUT MOE?
      dplyr::group_by(CCA) %>%
      dplyr::summarise(x.Count = sum(x.Count, na.rm = T),
                       tot = sum(tot, na.rm = T)) %>%
      dplyr::mutate(x = x.Count / tot) %>% #returns a mean
      dplyr::filter(!is.na(CCA))
    
  } 
  
  out <- dfOut$x
  names(out) <- dfOut$CCA
  
  if(return_df == T) {
    return(dfOut)
  } else {
    return(out) #returns a named vector of CCA-level statistics 
  }
  
}

# end of script #
