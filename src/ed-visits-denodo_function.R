

#*****************************************************
# Function to extract ED daily visits from denodo 
#*****************************************************

# function definition: 
extract_ed_visits <- function(startdate_id, 
                              enddate_id, 
                              site = "Lions Gate Hospital", 
                              denodo_vw = vw_eddata){
  
  # inputs: 
  # > startdate and enddate as integers
  # > denodo_view is the name of the table saved as a connection via dbplyr 
  
  # outputs: 
  # dataframe with dates and ed visit counts
  
  eddata <- 
    denodo_vw %>% 
    filter(facility_name == !!(site),  # !! used to unquote the actual argument "site" 
           start_date_id >= startdate_id, 
           start_date_id <= enddate_id) %>% 
    
    select(start_date_id, 
           patient_id, 
           facility_name) %>%  # show_query()
    
    collect() %>% 
    
    group_by(start_date_id) %>%
    summarise(num_ED_visits = n())  
    
    # long format, matching with census results: 
  eddata %>%   
    mutate(nursing_unit_cd = rep(NA, nrow(eddata))) %>% 
    select(start_date_id, 
           nursing_unit_cd, 
           num_ED_visits) %>% 
    rename(date_id = start_date_id) %>% 
    
    # display in long format: 
    gather(key = "metric",
           value = "value", 
           -c(date_id, nursing_unit_cd))
  
  
}




# test the function: ------
# library(beepr)
# 
# edvisits <- extract_ed_visits("20181212", 
#                               "20181220"); beep()
