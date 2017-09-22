

# Function specification: 
# takes start and end date, returns daily admits for relevant units. 



## get admissions data: 
extractAdmissions <- function(startdate, enddate){
      
      # ensure packages are available: 
      stopifnot(c(require("RODBC"), 
                  require("sqldf"), 
                  require("dplyr"), 
                  require("reshape2")))
      
      # write out query: 
      
      query1 <- paste0("SELECT [AdmissionFacilityLongName], AdjustedAdmissionDate, [AdmissionNursingUnitCode], [AdmissionNursingUnitDesc] FROM [ADTCMart].[ADTC].[vwAdmissionDischargeFact] WHERE [AdmissionFacilityLongName]= 'Lions Gate Hospital' AND AdjustedAdmissionDate BETWEEN '",
                       startdate, "'", 
                       " AND '", 
                       enddate, "'", 
                       " ORDER BY AdjustedAdmissionDate, [AdmissionNursingUnitCode], [AdmissionNursingUnitDesc];") 
      
      # pull from adtc: 
      cnx <- odbcConnect("nayef_cnxn") 
      admData <- data.frame(sqlQuery(cnx, query1))
      
      # USING SQLDF::sqldf TO RUN SQL COMMANDS ON DATA: 
      admData2 <- sqldf("SELECT [AdmissionFacilityLongName], AdjustedAdmissionDate, [AdmissionNursingUnitCode], [AdmissionNursingUnitDesc], COUNT(*) as num_cases FROM admData GROUP BY [AdmissionFacilityLongName], AdjustedAdmissionDate, [AdmissionNursingUnitCode], [AdmissionNursingUnitDesc]")
      
      admData2 <- select(admData2, 2:ncol(admData2)) %>% 
            filter(AdmissionNursingUnitCode %in% 
                         c("EIP", "2E", "4E", "4W",
                           "5E", "6E", "6W", "7E",
                           "ICU", "MIU", "7W",
                           "Carlile Youth CD Ctr - IP")) %>% 
            mutate(AdjustedAdmissionDate=as.Date(AdjustedAdmissionDate))
      return(admData2)
}



# test function: 
# extractAdmissions("2017-01-01", "2017-01-10")
