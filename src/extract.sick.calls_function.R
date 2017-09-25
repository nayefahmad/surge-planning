

# this script reads in sick call data, outputs cleaned version for analysis. This script only needs to be run once. 


# example of LOCF() 
# library("DescTools")
# d.frm <- data.frame(
#       tag=rep(c("mo", "di", "mi", "do", "fr", "sa", "so"), 4)
#       , val=rep(c(runif(5), rep(NA,2)), 4) )
# 
# d.frm$locf <- LOCF( d.frm$val )
# d.frm


library("dplyr")
# rm(list=ls())

# read in data: 
calls.orig <- read.csv("\\\\vch.ca/departments/Projects (Dept VC)/Patient Flow Project/Coastal HSDA/2017 Requests/2017.09.21 Long weekend surge planning/results/clean data/LGH Sick Hours-COPY.csv", 
                       stringsAsFactors = FALSE, 
                       na.strings = c("", NA))

calls <- calls.orig
names(calls) <- tolower(names(calls))

str(calls)
summary(calls)


# new columns with filled in values 
calls$site.description2 <- LOCF(calls$site.description)
calls$unit2 <- LOCF(calls$unit)
calls$date2 <- LOCF(calls$date)
calls$dow2 <- LOCF(calls$dow)
calls$reason2 <- LOCF(calls$reason)
calls$job.family2 <- LOCF(calls$job.family)
calls$jobcode2 <- LOCF(calls$jobcode)

str(calls)
summary(calls)


# write data to csv: 
write.csv(calls, 
          file="\\\\vch.ca/departments/Projects (Dept VC)/Patient Flow Project/Coastal HSDA/2017 Requests/2017.09.21 Long weekend surge planning/results/output from src/LGH-Sick-Hours_with-old-columns.csv", 
          row.names = FALSE)



# remove old columns: 
calls.updated <- select(calls, -c(1:7)) %>% 
      select(2:8,1)
str(calls.updated)


# write to csv: 
write.csv(calls.updated, 
          file="\\\\vch.ca/departments/Projects (Dept VC)/Patient Flow Project/Coastal HSDA/2017 Requests/2017.09.21 Long weekend surge planning/results/output from src/LGH-Sick-Hours_updated.csv", 
          row.names = FALSE)



