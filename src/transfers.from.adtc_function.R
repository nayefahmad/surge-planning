

# Function specification: 
# takes start and end date, returns daily transfers in for relevant units. 

transferData <- function(startdate, enddate){
      
      # ensure packages are available: 
      stopifnot(c(require("RODBC"), 
                  require("sqldf"), 
                  require("dplyr"), 
                  require("reshape2")))
      
      query2 <- paste0("SELECT [ToFacilityLongName], [TransferDate], [ToNursingUnitCode] FROM [ADTCMart].[ADTC].[vwTransferFact] WHERE [ToFacilityLongName]= 'Lions Gate Hospital' AND [TransferDate] BETWEEN '",
                       startdate, "'", " AND '", enddate, "'",
                       " ORDER BY [TransferDate], [ToNursingUnitCode];")
      
      # pull data from ADTC using the ODBC connection
      cnx <- odbcConnect("cnx_SPDBSCSTA001") 
      transferData <- data.frame(sqlQuery(cnx, query2))
      
      # USING SQLDF::sqldf TO RUN SQL COMMANDS ON DATA: 
      transferData2 <- sqldf("SELECT [ToFacilityLongName], [TransferDate], [ToNursingUnitCode], COUNT(*) as num_cases FROM transferData GROUP BY [ToFacilityLongName], [TransferDate], [ToNursingUnitCode] ORDER BY [ToFacilityLongName], [TransferDate], [ToNursingUnitCode]")
      
      transferData2 <- select(transferData2, 2:ncol(transferData2)) %>% 
            filter(ToNursingUnitCode %in% 
                         c("EIP", "2E", "4E", "4W", "5E",
                           "6E", "6W", "7E", "ICU", "MIU",
                           "7W", "Carlile Youth CD Ctr - IP")) %>% 
            mutate(TransferDate=as.Date(TransferDate))
      
      return(transferData2)
}


# test the function: 
# transferData("2017-01-01", 
#              "2017-01-05")

