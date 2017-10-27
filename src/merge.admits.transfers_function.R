

#*************************************
# FUNCTION TO MERGE ADMITS AND TRANSFERS FOR SPECIFIED DATES 
#*************************************

# rm(list=ls())


# define function: ---------------
merge.admits.transf <- function(admits_data, 
                                transfer_data, 
                                startdate, 
                                enddate){
      
      # input: df with admits over a time range and another df with transfers
      # output: df with merge on date
      
      # ensure required packages are loaded: 
      stopifnot(c(require("RODBC"), 
                  require("sqldf"), 
                  require("dplyr"), 
                  require("reshape2"), 
                  require("lubridate")))
            
      dates <- seq(ymd(startdate), ymd(enddate), by="day") # %>% print 
      units <- c("EIP", "2E", "4E", "4W", "5E", "6E",
                 "6W", "7E", "ICU", "MIU", "7W", "Carlile Youth CD Ctr - IP")
      admits_data <- mutate(admits_data, 
                            AdjustedAdmissionDate=ymd(AdjustedAdmissionDate))
      
      left_table <- data.frame(date=rep(dates, each=length(units)), 
                               unit =rep(units, length(dates))) # %>% print 
      
      
      left_and_admits <- sqldf("SELECT date, unit, AdjustedAdmissionDate, AdmissionNursingUnitCode, num_cases FROM left_table LEFT JOIN admits_data ON (date=AdjustedAdmissionDate and unit=AdmissionNursingUnitCode)") # %>% print 
      
      admits_and_transfers <- sqldf("SELECT date, unit, AdjustedAdmissionDate, AdmissionNursingUnitCode, l.num_cases as admits, ToNursingUnitCode, t.num_cases as transfers FROM left_and_admits l LEFT JOIN transfer_data t ON (date=TransferDate AND unit=ToNursingUnitCode)") # %>% print 
      
      
      admits_and_transfers <- 
            mutate(admits_and_transfers, 
                   admits=sapply(admits, 
                                 function(x){if (is.na(x)== TRUE){0} else {x}}), 
                   transfers=sapply(transfers,
                                    function(x){if (is.na(x)== TRUE){0} else {x}}),             
                   admits_and_transf=admits+transfers ) %>%
            
            select(date, unit, admits, transfers, admits_and_transf)  # %>% print
      
      
      final_admits_and_transfers <- 
            melt(admits_and_transfers, id.vars = c("unit", "date")) %>% 
            filter(variable=="admits_and_transf") %>% 
            dcast(unit ~ date) # %>% print 
      
      return(final_admits_and_transfers)

}


#*********************************************
# test the function: ------------
# source("admits.from.adtc_function.R")
# source("transfers.from.adtc_function.R")
# 
# admits <- extractAdmissions("2016-10-07",
#                             "2016-10-11")
# transfers <- transferData("2016-10-07", 
#                           "2016-10-11")
#              
# merged <- merge.admits.transf(admits, transfers, 
#                               "2016-10-07", 
#                               "2016-10-11") %>% print 
