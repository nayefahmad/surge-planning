

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
                  require("tidyr"), 
                  require("reshape2"), 
                  require("lubridate")))
            
      dates <- seq(ymd(startdate), ymd(enddate), by="day") # %>% print 
      units <- c("EIP", 
                 "2E",
                 "3E", 
                 "3W", 
                 "4E",
                 "4W",
                 "5E",
                 "6E",
                 "6W",
                 "7E",
                 "7W", 
                 "ICU",
                 "MIU",
                 "7W", 
                 "Carlile Youth CD Ctr - IP")
      admits_data <- mutate(admits_data, 
                            AdjustedAdmissionDate=ymd(AdjustedAdmissionDate))
      
      left_table <- data.frame(date=rep(dates, each=length(units)), 
                               unit =rep(units, length(dates))) # %>% print 
      
      
      left_and_admits <-  left_table %>% 
            left_join(admits_data, 
                      by = c("date" = "AdjustedAdmissionDate", 
                             "unit" = "AdmissionNursingUnitCode"))  # %>% print
      
      admits_and_transfers <- left_and_admits %>% 
            left_join(transfer_data, 
                      by = c("date" = "TransferDate", 
                             "unit" = "ToNursingUnitCode")) %>% 
            rename(admits = num_cases.x, 
                    transfers = num_cases.y)  # %>% print
            
            
      admits_and_transfers <- admits_and_transfers %>% 
            replace_na(replace = list(admits = 0, 
                                      transfers = 0)) %>% 
            
            mutate(admits_and_transf = admits + transfers) %>%
            
            select(date, unit, admits, transfers, admits_and_transf) %>%
            
            # change format so dates are across columns
            melt(id.vars = c("unit", "date")) %>% 
            filter(variable=="admits_and_transf") %>%
            dcast(unit ~ date, sum) # %>% print
      
      return(admits_and_transfers)

}


#*********************************************
# test the function: ------------
# source("admits.from.adtc_function.R")
# source("transfers.from.adtc_function.R")
# 
admits <- extractAdmissions("2016-10-07",
                            "2016-10-11")
transfers <- transferData("2016-10-07",
                          "2016-10-11")

merged <- merge.admits.transf(admits, transfers,
                              "2016-10-07",
                              "2016-10-11")  # %>% print
