

#*******************************
# LGH SURGE PLANNING: EXTRACT PAST YEAR ADTC data, ed visits 
#*******************************

library("here")
library("readr")

# rm(list=ls())

# list.files()

# source data extraction functions: --------------
source(here("src", "admits.from.adtc_function.R"))  # ignore output
source(here("src", "ed.visits.from.edmart_function.R"))
source(here("src", "census.from.adtc_function.R"))
source(here("src", "transfers.from.adtc_function.R"))
source(here("src", "merge.admits.transfers_function.R"))

# 1. EXTRACT PAST YEAR DATA: ----------------------
startdate.past.year <- '2017-02-12'
enddate.past.year <- '2017-02-20'

census.df <- extractCensusData(startdate.past.year, 
                                enddate.past.year, format="wide")

admits.df <- extractAdmissions(startdate.past.year, 
                               enddate.past.year)  

transfers.df <- transferData(startdate.past.year, 
                              enddate.past.year)

ed_data.df <- extractED_data(startdate.past.year, 
                              enddate.past.year, 
                              ctas=FALSE, edArea=FALSE)

# merge admits and transfers: 
admits_and_transfers.df <- merge.admits.transf(admits.df, 
                                                transfers.df, 
                                                startdate.past.year, 
                                                enddate.past.year)



# 2. Write stuff to csv: ----------------------
# lubridate doesn't play well with here(): 
detach("package:lubridate", unload=TRUE)

output.path <- here("results", 
                    "output from src") 


write_csv(census.df, 
          paste0(output.path, "/census.csv"))

write_csv(admits_and_transfers.df, 
          paste0(output.path, "/admits-and-transfers.csv"))

write.csv(ed_data.df, 
          paste0(output.path, "/ed-visits.csv"))

#************************************

