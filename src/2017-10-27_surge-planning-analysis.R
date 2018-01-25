

#*******************************
# LGH SURGE PLANNING: EXTRACT PAST YEAR ADTC data, ed visits 
#*******************************

# rm(list=ls())

# list.files()

# source data extraction functions: --------------
source("admits.from.adtc_function.R")  # ignore output
source("ed.visits.from.edmart_function.R")
source("census.from.adtc_function.R")
source("transfers.from.adtc_function.R")
source("merge.admits.transfers_function.R")

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
output.path <- "\\\\vch.ca/departments/Projects (Dept VC)/Patient Flow Project/Coastal HSDA/2017 Requests/2017.09.21 Long weekend surge planning/results/output from src" 


write.csv(census.df, 
          file = paste0(output.path, "/census.csv"),
          row.names = FALSE)

write.csv(admits_and_transfers.df, 
          file = paste0(output.path, "/admits-and-transfers.csv") ,
          row.names = FALSE)

write.csv(ed_data.df, 
          file = paste0(output.path, "/ed-visits.csv"),
          row.names = FALSE)

#************************************

