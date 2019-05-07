
#******************************
# this script reads in sick call data, outputs cleaned version for analysis. This script only needs to be run once. 
#******************************

# example of LOCF() 
# library("DescTools")
# d.frm <- data.frame(
#       tag=rep(c("mo", "di", "mi", "do", "fr", "sa", "so"), 4)
#       , val=rep(c(runif(5), rep(NA,2)), 4) )
# 
# d.frm$locf <- LOCF( d.frm$val )
# d.frm


library("dplyr")
library("here")
library("DescTools")

# rm(list=ls())

# set dates we care about: 
startdate.past.year <- '2017-06-29'
enddate.past.year <- '2017-07-05'
past.year.interval <- seq(as.Date(startdate.past.year), 
                          as.Date(enddate.past.year), 
                          by="1 day")


# read in data: 
calls.orig <- read_csv(here("data",
                            "2018-06-18_LGH_sick_call_staff_scheduling_data.csv"))

calls <- calls.orig %>% 
      select(-`Labor Agreement`)

names(calls) <- tolower(names(calls))

str(calls)
summary(calls)

# replace NAs with 0: 
# calls[is.na(calls)] <- 0

# new columns with filled in values 
calls$site2 <- LOCF(calls$site)
calls$unit2 <- LOCF(calls$unit)
calls$date2 <- LOCF(calls$date)
calls$day.of.week2 <- LOCF(calls$`day of week`)
# calls$reason2 <- LOCF(calls$reason)
calls$job.title2 <- LOCF(calls$`job title`)
calls$jobcode2 <- LOCF(calls$`job code`)

str(calls)
summary(calls)


# write data to csv: 
write_csv(calls %>% 
                select(site2, 
                       unit2, 
                       date2, 
                       day.of.week2, 
                       code,
                       job.title2, 
                       jobcode2), 
                # filter(date2 %in% past.year.interval),  # todo: why doesn't filtering work? 
          here("results", 
               "output from src", 
               "2018-06-18_lgh_sick-call-data.csv"))
          






