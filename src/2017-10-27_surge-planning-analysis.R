

#*******************************
# LGH SURGE PLANNING 
#*******************************


library("reshape2")
library("dplyr")
library("lubridate") 
library("RODBC")
library("proto")
library("RSQLite")
library("sqldf")

# rm(list=ls())

setwd("//vch.ca/departments/Projects (Dept VC)/Patient Flow Project/Coastal HSDA/2017 Requests/2017.09.21 Long weekend surge planning/src")

# list.files()

# source data extraction functions: --------------
source("admits.from.adtc_function.R")  # ignore output
source("ed.visits.from.edmart_function.R")
source("census.from.adtc_function.R")
source("transfers.from.adtc_function.R")
source("merge.admits.transfers_function.R")

# 1. EXTRACT PAST YEAR DATA: ----------------------
startdate2016 <- '2016-10-07'
enddate2016 <- '2016-10-11'

census2016 <- extractCensusData(startdate2016, 
                                enddate2016, format="wide")

admits2016 <- extractAdmissions(startdate2016, 
                               enddate2016)  

transfers2016 <- transferData(startdate2016, 
                              enddate2016)

ed_data2016 <- extractED_data(startdate2016, 
                              enddate2016, 
                              ctas=FALSE, edArea=FALSE)

# merge admits and transfers: 
admits_and_transfers2016 <- merge.admits.transf(admits2016, 
                                                transfers2016, 
                                                startdate2016, 
                                                enddate2016)



# 2. Copy stuff: ----------------------
write.csv(census2016, file="\\\\vch.ca/departments/Projects (Dept VC)/Patient Flow Project/Coastal HSDA/2017 Requests/2017.09.21 Long weekend surge planning/results/output from src/census.csv", row.names = FALSE)

write.csv(admits_and_transfers2016, file="\\\\vch.ca/departments/Projects (Dept VC)/Patient Flow Project/Coastal HSDA/2017 Requests/2017.09.21 Long weekend surge planning/results/output from src/admits-and-transfers.csv", row.names = FALSE)

write.csv(ed_data2016, file="\\\\vch.ca/departments/Projects (Dept VC)/Patient Flow Project/Coastal HSDA/2017 Requests/2017.09.21 Long weekend surge planning/results/output from src/ed-visits.csv", row.names = FALSE)


