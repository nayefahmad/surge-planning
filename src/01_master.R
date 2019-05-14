
#***********************************************************
# LGH SURGE PLANNING: EXTRACT PAST YEAR ADTC data, ed visits
# 2019-05-03
# Nayef 


#***********************************************************

library(odbc)
library(dbplyr)
library(magrittr)  
library(tidyverse)
library(here)

# rm(list = ls())

# 1) parameters: --------------
startdate_id <- '20180517'
enddate_id <- '20180522'

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
source(here("src", 
            "setup-denodo_function.R"))

setup_denodo()


# 3) Import functions for pulling data: ---------
source(here("src", 
            "census-denodo_function.R"))
source(here("src", 
            "ed-visits-denodo_function.R"))
source(here("src", 
            "admits-denodo_function.R"))


# 4) Run functions: ----------

# LGH data: 
census <- extract_census(startdate_id, 
                         enddate_id)

ed_visits <- extract_ed_visits(startdate_id, 
                               enddate_id)

admits <- extract_admits(startdate_id, 
                         enddate_id)


# LGH HOpe Centre data: 
census_hope_centre <- extract_census(startdate_id, 
                                     enddate_id, 
                                     site = "LGH HOpe Centre", 
                                     n_units = "LGH MIU")

admits_hope_centre <- extract_admits(startdate_id, 
                                     enddate_id, 
                                     site = "LGH HOpe Centre", 
                                     n_units = "LGH MIU")



# join all together in one df: 
df1.past_year_data <- 
      census %>% 
      bind_rows(census_hope_centre, 
                admits, 
                admits_hope_centre, 
                ed_visits)  






# 5) write output: -----------
write_csv(df1.past_year_data,
          here::here("results", 
                         "output from src", 
                         "2019-05-08_lgh_historical-admits-transfers-ed-visits.csv"))
                         
