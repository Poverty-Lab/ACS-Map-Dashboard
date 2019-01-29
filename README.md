# ACS Map Dashboard

The [ACS Map Dashboard](https://povertylab.shinyapps.io/ACS-Map-Dashboard/) produces customizable visualizations using the 2012-2016 5-year [American Community Survey (ACS)](https://www.census.gov/programs-surveys/acs/about.html) estimates across the 77 [Chicago community areas (CCA)](http://www.encyclopedia.chicagohistory.org/pages/1760.html).

The map, bar plot, and tables produced are all exportable, allowing users to save graphics and data with the click of a button.

**For a tutorial, see https://www.youtube.com/watch?v=hSad5pmTYWI**

## Run App

Run the app in your browser by visiting https://povertylab.shinyapps.io/ACS-Map-Dashboard/. 

Run the app locally in [R](https://www.r-project.org/) or [RStudio](https://www.rstudio.com/products/rstudio/) by using the following lines of code:

```R
# install necessary packages
install.packages(pkgs = c("acs", "bitops", "DT" 
                           , "dplyr", "ggplot2", "mapproj" 
                           , "RCurl", "scales", "shiny"
                           , "viridisLite", "viridis", "zoo"))
                           
# load the shiny packages
library(shiny)

# Run shiny app from your R/RStudio Console
shiny::runUrl( url = "https://github.com/Poverty-Lab/ACS-Map-Dashboard/archive/master.zip" )

# end of script #

```

## Outline

Click to skip ahead to other sections: 

* [Overview](#overview)
* [Data](#data)
* [Census Tract to Chicago Community Areas Aggregation](#census-tract-to-chicago-community-area-aggregation)
* [User Interface (UI)](#user-interface-ui)
* [Code](#code)
* [Current Limitations](#current-limitations)
* [To Do Before Launch](#to-do-before-launch)
* [List of Features](#list-of-features)
* [Session Info](#session-info)


## Overview

This app produces customizable visualizations of 2012-2016 5 year ACS estimates by CCA. To do this, it requires that the user [select one of the countless tables](https://www.census.gov/programs-surveys/acs/technical-documentation/table-shells.html) from the ACS. Depending on the table, the user may also filter the table by one variable.

![Purpose](https://github.com/Poverty-Lab/ACS-Map-Dashboard/blob/master/Visuals/input_output.png)

*Click here to return to the [Outline](#outline).*

## Data

The ACS Map Dashboard retrives its data from the [Census Data Application Programming Interface (API)](https://www.census.gov/data/developers/guidance/api-user-guide.html), which requests data from the [U.S. Census Bureau](https://www.census.gov/en.htmldatasets).

To access the API, we use the [`acs`](https://cran.r-project.org/web/packages/acs/acs.pdf) package to download and manipulate ACS estimate data from the U.S. Census Bureau. At the moment, we only use the data from the 2012-2016 5 year ACS estimates.

*Click here to return to the [Outline](#outline).*

## Census Tract to Chicago Community Area Aggregation

### Background

[Census tract boundaries](https://www.census.gov/geo/reference/gtc/gtc_ct.html) are small geogrpahies that typically contain anywhere from 1,200 to 8,000 people. [Cook County, IL](https://www2.census.gov/geo/maps/dc10map/tract/st17_il/c17031_cook/DC10CT_C17031_000.pdf) contains 1,319 census tracts.

Around [800 of those census tracts](https://data.cityofchicago.org/Facilities-Geographic-Boundaries/Boundaries-Census-Tracts-2010/5jrd-6zik/data) reside in the city of Chicago. However, census tracts do not always share borders with the city's 77 community areas (i.e. neighborhoods).

### Methodology

We allocate census tract statistics to their corresponding neighborhoods based on the proportion of individuals and households in a tract that belong to that neighborhood. This is done by leveraging [block-level information published by the census](https://data.cityofchicago.org/Facilities-Geographic-Boundaries/Boundaries-Census-Blocks-2010/mfzt-js4n/data). 

[Census blocks](https://www.census.gov/newsroom/blogs/random-samplings/2011/07/what-are-census-blocks.html) are the smallest geographic unit with data published by the census. The census does not provide any demographic statistics at the block-level for privacy reasons, but they do provide the number of individuals and households within each block. 

With this information, we are able to calculate the number of individuals and households from a given tract that belong to each neighborhood. We then allocate a tracts’ statistics, e.g. the number of individuals employed, or the mean household income, into the corresponding neighborhood in proportion to the neighborhood’s actual population  not a proxy.  

*Click here to return to the [Outline](#outline).*

## User Interface (UI)

The user selects the data to be represented on the left-hand pane. The graphic can be customized in the right-hand pane. The graphic is presented in the middle pane.

![Map Tab](https://github.com/Poverty-Lab/ACS-Map-Dashboard/blob/master/Visuals/ACS_MD_Map.png)

![Bar Plot Tab](https://github.com/Poverty-Lab/ACS-Map-Dashboard/blob/master/Visuals/ACS_MD_BP.png)

![Table Tab](https://github.com/Poverty-Lab/ACS-Map-Dashboard/blob/master/Visuals/ACS_MD_TB.png)

*Click here to return to the [Outline](#outline).*


## Code

The app is organized around three `.R` scripts:

| **Script Name** | **Description** |
| :-------------: | :-------------: |
| [`global.R`](global.R) | Imports all necessary objects into the global environment. Specifically, this scripts does two things: 1) sources custom [ggplot2](http://ggplot2.tidyverse.org/index.html) themes and [census tract](https://www.census.gov/geo/reference/gtc/gtc_ct.html) to CCA aggregation function found in [/Poverty-Lab/ACS-Map-Dasboard/R](https://github.com/Poverty-Lab/ACS-Map-Dashboard/tree/master/R); and 2) imports `.rds` objects that are found in [/Poverty-Lab/ACS-Map-Dasboard/Data](https://github.com/Poverty-Lab/ACS-Map-Dashboard/tree/master/Data). |
| [`ui.R`](ui.R) | Creates the [user-interface elements](https://www.usability.gov/how-to-and-tools/methods/user-interface-elements.html) that allow users to select data and navigate across the Map, Bar Plot, and Table tabs on the page. |
| [`server.R`](server.R) | Stores the data and logic used to render the map, barplot, and table that the user observers in the user-interface. This script uses [reactive programming](https://shiny.rstudio.com/articles/reactivity-overview.html) to [provide the recipes that should be used to update the outputs](https://www.rstudio.com/resources/webinars/shiny-developer-conference/). |

*Click here to return to the [Outline](#outline).*


## Workflow

Below is a visual representation of how the `global.R`, `ui.R`, and `server.R` script work together to produce the ACS Map Dashboard:

![Workflow](https://github.com/Poverty-Lab/ACS-Map-Dashboard/blob/master/Visuals/ACS_Map_Dashboard_Workflow_V1.png)

*Click here to return to the [Outline](#outline).*

## Features

|Feature|Current Master Branch|Launch Version|Wish-list Version|
|---|---|---|---|
|**General**| | | |
|  Confirmed tract:CCA conversion table|x|x|x|
|**Data Options**| | | |
|  Dropdown menu|x|x|x|
|  Calculate by count/proportion/mean|x|x|x|
|  Calculate by individual/household|x|x|x|
|  Specify total/percent/per 100k|x|x|x|
|  Specify denominator for above calculation|x|x|x|
|**Map**| | | |
|  Custom title|x|x|x|
|  Geography labels| | |x|
|  Show as percent of whole| | |x|
|  Lab themes|x|x|x|
|  Save graphic button|x|x|x|
|  Show code button| | |x|
|**Bar Plot**| | | |
|  Custom title|x|x|x|
|  Direction (desc/ascending)|x|x|x|
|  Number of geographies to include|x|x|x|
|  Lab themes|x|x|x|
|  Error bars|x|x|x|
|  Save graphic button|x|x|x|
|  Show code button| | |x|
|**Table**| | | |
|  Save table button|x|x|x|
|**Misc**| | | |
|  Leaflet plots| | |x|

*Click here to return to the [Outline](#outline).*

## Session Info

This Shiny app was built using the following version of R, OS, and attached packcages:

```R
R version 3.4.4 (2018-03-15)
Platform: x86_64-apple-darwin15.6.0 (64-bit)
Running under: macOS High Sierra 10.13.2

Matrix products: default
BLAS: /System/Library/Frameworks/Accelerate.framework/Versions/A/Frameworks/vecLib.framework/Versions/A/libBLAS.dylib
LAPACK: /Library/Frameworks/R.framework/Versions/3.4/Resources/lib/libRlapack.dylib

locale:
[1] en_US.UTF-8/en_US.UTF-8/en_US.UTF-8/C/en_US.UTF-8/en_US.UTF-8

attached base packages:
[1] stats     graphics  grDevices utils     datasets  methods  
[7] base     

other attached packages:
 [1] bindrcpp_0.2      viridis_0.5.0     viridisLite_0.3.0
 [4] scales_0.5.0      RCurl_1.95-4.10   mapproj_1.2-5    
 [7] maps_3.2.0        ggplot2_2.2.1     dplyr_0.7.4      
[10] DT_0.4            bitops_1.0-6      acs_2.1.3        
[13] XML_3.98-1.10     stringr_1.3.0     shiny_1.0.5      

loaded via a namespace (and not attached):
 [1] Rcpp_0.12.16     compiler_3.4.4   pillar_1.2.1    
 [4] plyr_1.8.4       bindr_0.1.1      tools_3.4.4     
 [7] digest_0.6.15    evaluate_0.10.1  jsonlite_1.5    
[10] tibble_1.4.2     gtable_0.2.0     pkgconfig_2.0.1 
[13] rlang_0.2.0      crosstalk_1.0.0  curl_3.1        
[16] yaml_2.1.18      gridExtra_2.3    knitr_1.20      
[19] httr_1.3.1       htmlwidgets_1.0  rprojroot_1.3-2 
[22] grid_3.4.4       glue_1.2.0       R6_2.2.2        
[25] rmarkdown_1.9    magrittr_1.5     backports_1.1.2 
[28] htmltools_0.3.6  rsconnect_0.8.8  assertthat_0.2.0
[31] mime_0.5         xtable_1.8-2     colorspace_1.3-2
[34] httpuv_1.3.6.2   labeling_0.3     stringi_1.1.7   
[37] lazyeval_0.2.1   munsell_0.4.3 
```

