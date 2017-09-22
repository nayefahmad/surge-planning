
# Function specification: 



# todo: ------
# require: sqldf


extractCensusData <- function(startdate, enddate, format='wide'){
      
      # ensure packages are available: 
      stopifnot(c(require("RODBC"), 
                  require("sqldf"), 
                  require("dplyr"), 
                  require("reshape2")))
      
      # write out query: 
      query1 <- paste0("SELECT [FacilityLongName], CensusDate, [NursingUnitCode], [NursingUnitDesc] FROM [ADTCMart].[ADTC].[vwCensusFact] WHERE [FacilityLongName]='Lions Gate Hospital' AND CensusDate BETWEEN '",
                       startdate,
                       "'", " AND '", 
                       enddate, "'", 
                       " ORDER BY CensusDate, [NursingUnitCode], [NursingUnitDesc];")  
      # pull data from ADTC and save as dataframe: 
      cnx <- odbcConnect("nayef_cnxn") 
      censusData <- data.frame(sqlQuery(cnx, query1))
      
      # USING SQLDF::sqldf TO RUN SQL COMMANDS ON DATA: 
      censusData2 <- sqldf("SELECT *, COUNT(*) as num_cases FROM censusData GROUP BY FacilityLongName, CensusDate, NursingUnitCode, NursingUnitDesc ORDER BY CensusDate, NursingUnitCode")
      
      # FINAL FORMATTING OF DATA:
      censusData2 <- filter(censusData2, NursingUnitCode %in% 
                                  c("EIP", 
                                    "2E",
                                    "4E",
                                    "4W",
                                    "5E",
                                    "6E",
                                    "6W",
                                    "7E", 
                                    "ICU",
                                    "MIU",
                                    "7W", 
                                    "Carlile Youth CD Ctr - IP")) %>%
            mutate(CensusDateChar = as.character(CensusDate)) %>% 
            select(CensusDateChar, 
                   NursingUnitCode,
                   num_cases)
      
      # str(censusData2)  # note that this is not the format we want. We would need to put it into a pivottable to reformat. __OR__....
      
      # reshape the data to the form we want: 
      if(format=='wide'){
            cData2_long <- melt(censusData2)  
            # first melt the data, then dcast to the format you want. 
            
            cData2_recast <- dcast(cData2_long, NursingUnitCode ~ CensusDateChar)
            return(cData2_recast)
            
      } else if(format=='long'){
            return(censusData2)
      }
}



# test the function: ----------
census2016 <- extractCensusData("2016-09-02", 
                                "2016-09-06",
                                format="wide")
