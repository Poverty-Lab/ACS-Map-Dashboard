# ACS Dashboard

## Run App

Run the app yourself using the following lines of code:

```R
# install necessary packages
install.packages( pkgs = c("acs", "bitops", "DT" 
                           , "dplyr", "ggplot2", "lettercase" 
                           , "RCurl", "scales", "shiny" ) )
                           
# load the shiny packages
library( shiny )

# Run shiny app from your R/RStudio Console
shiny::runUrl( url = "https://github.com/Poverty-Lab/ACS-Map-Dashboard/archive/master.zip" )

# end of script #

```

## Outline

Click to skip ahead to other sections: 

* [Overview](README.md#overview)
* [User Interface (UI)](README.md#user-interface-ui)
* [Code](README.md#code)
* [Current Limitations](README.md#current-limitations)
* [To Do Before Launch](README.md#to-do-before-launch)

Features included in each branch:

|Feature|Current Master Branch|Launch Version|Wish-list Version|
|---|---|---|---|
|**General**| | | |
|  Confirmed tract:CCA conversion table|x|x|x|
|**Data Options**| | | |
|  Dropdown menu|x|x|x|
|  Calculate by count/proportion/mean|x|x|x|
|  Calculate by individual/household|x|x|x|
|  Specify total/percent/per 100k|x|x|x|
|**Map**| | | |
|  Custom title|x|x|x|
|  Geography labels| | |x|
|  Show as percent of whole| | |x|
|  Lab themes| | |x|
|  Save graphic button|x|x|x|
|  Show code button| | |x|
|**Bar Plot**| | | |
|  Custom title|x|x|x|
|  Direction (desc/ascending)|x|x|x|
|  Number of geographies to include|x|x|x|
|  Lab themes| | |x|
|  Error bars| |x|x|
|  Save graphic button|x|x|x|
|  Show code button| | |x|
|**Table**| | | |
|  Save table button|x|x|x|
|**Misc**| | | |
|  Leaflet plots| | |x|

*************

## Overview

This app produces customizable visualizations of ACS statistics by CCA. The app can produce maps, bar plots, and tables of most ACS variables by CCA. To do this, it takes one of two types of inputs: pre-loaded and aggregated data from a file, or ACS data downloaded in the app via a census API.  

![Purpose](https://github.com/Poverty-Lab/ACS-Map-Dashboard/blob/master/Visuals/2018-01-05-acs_dashboard_purpose.png)

Click here to return to the [Outline](README.md#outline).

## User Interface (UI)

The user selects the data to be represented on the left-hand pane. The graphic can be customized in the right-hand pane. The graphic is presented in the middle pane.

![Map Tab](https://github.com/Poverty-Lab/ACS-Map-Dashboard/blob/master/Visuals/2018-01-05-acs_dashboard_ss1.png)

![Bar Plot Tab](https://github.com/Poverty-Lab/ACS-Map-Dashboard/blob/master/Visuals/2018-01-05-acs_dashboard_ss2.png)

![Table Tab](https://github.com/Poverty-Lab/ACS-Map-Dashboard/blob/master/Visuals/2018-01-05-acs_dashboard_ss3.png)

Click here to return to the [Outline](README.md#outline).


## Code

The app is organized according to the table 1, operating on two “tracks” depending on the input given. 

When a user selects a premade plot (the top left-most menu in the UI example above), the app simply draws a graphic of this variable from a preexisting dataset that includes the CCA and the statistic. When a user inputs an ACS variable to produce a custom plot from (the text entry box in the upper-left), the app downloads that data via a census API, aggregates it to CCA, and then draws a graphic.

Ultimately, the following files are loaded by the app:

* For premade plots 
    + CCA Statistics.csv: Preselected statistics by CCA.
    + CCA Statistics Fortified.RData: The above statistics in a format that can be read by ggplot2.
    + Preselected Variables.csv: Only the names of the above variables, for labeling purposes.

* For custom plots 
    + 2_Aggregation Function.R: The function that aggregates tract-level data downloaded via the census API to CCA level. This code uses the file Tract to CCA Aggregation Lookup.csv to do this.

* Miscellaneous
    + Themes.R: Includes ggplot themes for maps and barplots. 


### Figure 1. Code Workflow
![Workflow](https://github.com/Poverty-Lab/ACS-Map-Dashboard/blob/master/Visuals/2018-01-05-acs_dashboard_workflow.png)

Click here to return to the [Outline](README.md#outline).

## Current Limitations

1.	The census API for downloading ACS data, the R package acs, cannot load variables unless they conform to a specific 9-character format. Not all variables conform to this format, even if they are available at the tract level.
2.	Margins of error cannot be aggregated accurately without individual-level data. We will have to use an approximation, but have not come up with one yet. 
3.	Cannot transform variables in current version 
4.	Various incomplete functionalities (see below)

Click here to return to the [Outline](README.md#outline).

## To Do Before Launch

*This was last updated on January 5, 2018*

### Required
- [x] Get this thing on gitlab: 1 hour, Isaac
- [ ] Host online: 1 hour
- [x] Write a one-page readme on use: 1 hour, Isaac
- [x] Write a supplemental one- or two-pager explaining our aggregation method and link to it in the app: 1-2 hours, Isaac
- [ ] Address margin of error calculation: 5-10 hours, statistical and programming expertise
- [ ] Add ability to transform statistics from a total to a percent/per-capita number: 5-10 hours, R and ACS expertise 
- [ ] Fix save button (otherwise plots can be saved by right-clicking): 1 hour, R expertise

### Wish List
- [ ] Improve plot customization options, functionality (titles, axis labels, showing statistic as a percent, etc.): 10 hours, R Shiny expertise
- [ ] Add a colorbrewer pallet for each lab: 2-3 hours, R expertise 
- [ ] Clean UI text, warnings: 2-3 hours, R Shiny expertise 
- [ ] Improve and validate the Show Code functionality: 2-3 hours, R expertise 
- [ ] Others - see table at top of readme

Click here to return to the [Outline](README.md#outline).










