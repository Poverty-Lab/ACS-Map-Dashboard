#
# Author:   Isaac Ahuvia and Cristian Nuno
# Date:     Aril 26, 2018
# Purpose:  Define ggplot2 themes to be used in the Shiny app
#

# load necessary packages
require( ggplot2 )

####  Plot Setup  ####
themeTitle <- theme(legend.title = element_blank(),
                    plot.title = element_text( hjust = 0.5, size = 20 ) )

themeMOE <- theme(panel.background=element_blank(),
                  axis.text.x = element_text( angle = 45, hjust = 1 ) )


# end of script #
