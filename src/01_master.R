
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
enddate_id <- '20180510'


# 2) set up database connections: -----------
cnx <- dbConnect(odbc::odbc(),
                 dsn = "cnx_denodo_spappcsta001")


vw_eddata <- dplyr::tbl(cnx, 
                        dbplyr::in_schema("publish", 
                                          "emergency"))
vw_adtc <- dplyr::tbl(cnx, 
                      dbplyr::in_schema("publish", 
                                        "admission_discharge"))
vw_census <- dplyr::tbl(cnx, 
                        dbplyr::in_schema("publish", 
                                          "census"))





