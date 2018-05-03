#
# Author:   Isaac Ahuvia and Cristian Nuno
# Date:     Aril 26, 2018
# Purpose:  Define ggplot2 themes to be used in the Shiny app
#

# load necessary packages
require( ggplot2 ) # just to be sure that ggplot2 is loaded in the Global Environment

####  Plot Setup  ####
themeMap <- theme(axis.line=element_blank(),
                  axis.text.x=element_blank(),
                  axis.text.y=element_blank(),
                  axis.ticks=element_blank(),
                  axis.title.x=element_blank(),
                  axis.title.y=element_blank(),
                  panel.background=element_blank(),
                  panel.border=element_blank(),
                  panel.grid.major=element_blank(),
                  panel.grid.minor=element_blank(),
                  plot.background=element_blank())

themeMOE <- theme(panel.background=element_blank(),
                  axis.text.x = element_text(angle = 45, hjust = 1))

# end of script #
