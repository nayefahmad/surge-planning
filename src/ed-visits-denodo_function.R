

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
  # dataframe with census dates and census counts, by nursing unit
  
  vw_census %>% 
    filter(facility_name == !!(site),  # !! used to unquote the actual argument "site" 
           census_date_id >= startdate_id, 
           census_date_id <= enddate_id, 
           nursing_unit_cd %in% n_units) %>% 
    
    select(census_date_id, 
           patient_id, 
           nursing_unit_cd, 
           facility_name) %>%  # show_query()
    
    collect() %>% 
    
    group_by(census_date_id, 
             nursing_unit_cd) %>%
    summarise(census = n()) %>% 
    
    # display in long format: 
    gather(key = "census",
           value = "value", 
           -c(census_date_id, nursing_unit_cd))
  
  
}




# test the function: ------
library(beepr)

census <- extract_census("20181212", 
                         "20181213"); beep()
