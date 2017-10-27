
library("labeling")
library("digest")
library("reshape2")
library("magrittr")
library("dplyr")
library("lazyeval")
library("lubridate") 
library("tidyr")
library("RODBC")
library("proto")
library("RSQLite")
# library("DBI")
library("gsubfn")
library("sqldf")

# rm(list=ls())

setwd("//vch.ca/departments/Projects (Dept VC)/Patient Flow Project/Coastal HSDA/2017 Requests/2017.08.23 LGH Surge Planning - Labour Day")

# list.files("//vch.ca/departments/Projects (Dept VC)/Patient Flow Project/Coastal HSDA/2017 Requests/2017.06.21 LGH Surge Planning - Canada Day")


# ignore outputs, just doing this to load functions: 
# source("2017.06.21 Surge planning - extract capplan fcasts from csv.R")  # specify a random csv when asked. 
source("H:/VCH files - Nayef/2017.08.15 R scripts/2017.07.10 Surge planning - extract census, admits, transfers.R")  # ignore output

source("H:/VCH files - Nayef/2017.08.15 R scripts/2017.07.04 Extract ED data.R")

# 1. EXTRACT PAST YEAR DATA: ----------------------
# BC Day is the first Monday of August 

startdate2016 <- '2016-10-07'
enddate2016 <- '2016-10-11'

census2016 <- extractCensusData(startdate2016, 
                                enddate2016, format="wide")

admits2016 <- admissionsActual(startdate2016, 
                               enddate2016)  

transfers2016 <- transferData(startdate2016, 
                              enddate2016)

ed_data2016 <- extractED_data(startdate2016, 
                              enddate2016, 
                              ctas=FALSE, edArea=FALSE)

# combine admits and transfers: 
dates <- seq(as.Date(startdate2016), as.Date(enddate2016), by="day") 
units <- c("EIP", "2E", "4E", "4W", "5E", "6E",
           "6W", "7E", "ICU", "MIU", "7W", "Carlile Youth CD Ctr - IP")
left_table <- data.frame(date=rep(dates, each=length(units)), 
                 unit =rep(units, length(dates)))


left_and_admits <- sqldf("SELECT date, unit, AdjustedAdmissionDate, AdmissionNursingUnitCode, num_cases FROM left_table LEFT JOIN admits2016 ON (date=AdjustedAdmissionDate and unit=AdmissionNursingUnitCode)")

admits_and_transfers <- sqldf("SELECT date, unit, AdjustedAdmissionDate, AdmissionNursingUnitCode, l.num_cases as admits, ToNursingUnitCode, t.num_cases as transfers FROM left_and_admits l LEFT JOIN transfers2016 t ON (date=TransferDate AND unit=ToNursingUnitCode)")


admits_and_transfers <- 
      mutate(admits_and_transfers, 
             admits=sapply(admits, function(x){if (is.na(x)== TRUE){0} else {x}}), 
             transfers=sapply(transfers, function(x){if (is.na(x)== TRUE){0} else {x}}),             
             admits_and_transf=admits+transfers ) %>%
      select(date, unit, admits, transfers, admits_and_transf) %>% print
      

final_admits_and_transfers <- 
      melt(admits_and_transfers, id.vars = c("unit", "date")) %>% 
            filter(variable=="admits_and_transf") %>% 
            dcast(unit ~ date) %>% print 



# 2. Copy stuff: ----------------------
write.table(census2016, "clipboard", sep="\t", row.names=FALSE)
write.table(final_admits_and_transfers, "clipboard", sep="\t", row.names=FALSE)
write.table(ed_data2016, "clipboard", sep="\t", row.names=FALSE)

