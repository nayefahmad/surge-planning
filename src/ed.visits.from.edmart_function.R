

#****************************
# Functions to extract ED Data
#****************************


library("reshape2")
library("dplyr")
library("RODBC")
library("RSQLite")
library("gsubfn")
library("sqldf")

# rm(list=ls())

# todo: -----
# include require() statements in the function


cnx <- odbcConnect("nayef_cnxn")

extractED_data <- function(startdate, enddate, ctas=TRUE, edArea=FALSE){
      # EDMart query: 
      query1 <- paste0("SELECT StartDate, FacilityLongName, TriageAcuityDescription, [TriageAcuityCode], FirstEmergencyAreaDescription, COUNT(*) AS num_cases FROM [EDMart].[dbo].[vwEDVisitIdentifiedRegional] WHERE FacilityID = '112' AND StartDate BETWEEN ", "'", startdate, "' AND '", enddate, "' GROUP BY [TriageAcuityCode], StartDate, FacilityLongName, TriageAcuityDescription, FirstEmergencyAreaDescription ORDER BY StartDate,[TriageAcuityCode], FirstEmergencyAreaDescription, FacilityLongName")
     
      # Pull data from data warehouse: 
      edData <- data.frame(sqlQuery(cnx, query1))
      
      if (ctas==TRUE && edArea==TRUE){
            return(edData)
            
      } else if (ctas==FALSE && edArea==FALSE) {
            # USING SQLDF::sqldf TO RUN SQL COMMANDS ON DATA: 
            edData2 <- sqldf("SELECT StartDate, FacilityLongName, SUM(num_cases) as num_cases FROM edData GROUP BY StartDate, FacilityLongName ORDER BY StartDate")
            
            return(edData2)
            
      } else if (ctas==TRUE && edArea==FALSE) {
            edData3 <- sqldf("SELECT StartDate, FacilityLongName, TriageAcuityDescription, [TriageAcuityCode], SUM(num_cases) as num_cases FROM edData GROUP BY StartDate, FacilityLongName, TriageAcuityDescription, [TriageAcuityCode] ORDER BY StartDate, TriageAcuityDescription, [TriageAcuityCode]")
            
            return(edData3)
      } else if (ctas==FALSE && edArea==TRUE) {
            edData4 <- sqldf("SELECT StartDate, FacilityLongName, FirstEmergencyAreaDescription, SUM(num_cases) as num_cases FROM edData GROUP BY StartDate, FacilityLongName, FirstEmergencyAreaDescription ORDER BY StartDate, FirstEmergencyAreaDescription")
            
      }
      
}


