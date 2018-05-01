#######################################
##      Tract to CCA Aggregation     ##
##      2. Aggregation Function      ##
#######################################


####  Setup  ####
library(dplyr)

####  Aggregate Function  ####
tractToCCA <- function(x, tractID
                       , type = c("Count", "Proportion", "Mean")
                       , level = c("Individual", "Household")
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
  if(!level %in% c("Individual", "Household")) {
    stop("level must be one of Individual, Household")
  }
  
  if(!"lookup" %in% ls()) {
    
    lookup <- read.csv( file = "https://raw.githubusercontent.com/Poverty-Lab/ACS-Map-Dashboard/master/Data/Tract%20Statistics.csv"
                        , header = TRUE
                        , stringsAsFactors = FALSE )
    
    lookup$tractID <- as.character(lookup$tractID)
  }
  if(!is.data.frame(lookup)) {
    stop("It looks like you already have something in your environment named 'lookup,' that is not the lookup dataframe required by this funciton. Please rename and delete it.")
  }
  if(is.data.frame(lookup)) {
    if(length(lookup) != 7 & nrow(lookup != 879)) {
      stop("It looks like you already have something in your environment named 'lookup,' that is not the lookup dataframe required by this funciton. Please rename and delete it.")
    }
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
    df$pop <- df$pop
    df$popProp <- df$pctPop
  } else if(level == "Household") {
    df$pop <- df$HH
    df$popProp <- df$pctHH
  }
  
  
  ## Aggregate
  if(type == "Count") {
    
    dfOut <- df %>%
      dplyr::mutate(x.Count = x * popProp) %>% #calculate total income for each tract-CCA pairing
      dplyr::group_by(CCA) %>%
      dplyr::summarise(x = sum(x.Count, na.rm = T)) %>% #returns a count
      dplyr::filter(!is.na(CCA))
    
  } else if(type == "Proportion") {
    
    dfOut <- df %>%
      dplyr::mutate(x.Count = x * pop) %>% #calculate total income for each tract-CCA pairing              ######### WHAT TO DO ABOUT MOE?
      dplyr::group_by(CCA) %>%
      dplyr::summarise(x.Count = sum(x.Count, na.rm = T),
                       pop = sum(pop, na.rm = T)) %>%
      dplyr::mutate(x = x.Count / pop) %>% #returns a proportion
      dplyr::filter(!is.na(CCA))
    
  } else if(type == "Mean") {
    
    dfOut <- df %>%
      dplyr::mutate(x.Count = x * pop) %>% #calculate total income for each tract-CCA pairing              ######### WHAT TO DO ABOUT MOE?
      dplyr::group_by(CCA) %>%
      dplyr::summarise(x.Count = sum(x.Count, na.rm = T),
                       pop = sum(pop, na.rm = T)) %>%
      dplyr::mutate(x = x.Count / pop) %>% #returns a mean
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


# ####  Testing  ####
# dfTract <- read.csv("L:\\Resources\\Stats and Graphics\\Mapping Dashboard\\Data\\Tract Statistics.csv", stringsAsFactors = F)
# 
# #count - African Americans by CCA
# tractToCCA(x = dfTract$Ind.Count.BlackAA, tractID = dfTract$tractID, type = "Count", level = "Individual")
# 
# #proportion - 
# 
# 
# #mean - 
# 
# 
# ## with ACS data
# library(acs)
# geog <- geo.make(state = "IL", county = 31, tract = "*")
# acs <- acs::acs.fetch(geography = geog, endyear = 2015, span = 5, variable = "B01002_001")
# results <- tractToCCA(x = estimate(acs), tractID = acs@geography$tract, type = "Mean", level = "Individual")
# View(data.frame(Statistic = results))

# end of script #
