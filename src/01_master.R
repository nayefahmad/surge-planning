
#***********************************************************
# LGH SURGE PLANNING: EXTRACT PAST YEAR ADTC data, ed visits
# 2019-05-03
# Nayef 


#***********************************************************

library(odbc)
library(dbplyr)
library(magrittr)  
library(tidyverse)

# 1) parameters: --------------
startdate_id <- '20180501'
enddate_id <- '20180501'

n_units_param <- c("LGH 2E",
                   "LGH 3E", 
                   "LGH 3W", 
                   "LGH 4E",
                   "LGH 4W",
                   "LGH 5E",
                   "LGH 6E",
                   "LGH 6W",
                   "LGH 7E",
                   "LGH 7W", 
                   "LGH 7W", 
                   "LGH EIP", 
                   "LGH ICU",
                   "LGH MIU"
                   )


# 2) set up database connections: -----------
cnx <- dbConnect(odbc::odbc(),
                 dsn = "cnx_denodo_spappcsta001")

vw_census <- dplyr::tbl(cnx, 
                        dbplyr::in_schema("publish", 
                                          "census"))
vw_eddata <- dplyr::tbl(cnx, 
                        dbplyr::in_schema("publish", 
                                          "emergency"))
vw_adtc <- dplyr::tbl(cnx, 
                      dbplyr::in_schema("publish", 
                                        "admission_discharge"))





