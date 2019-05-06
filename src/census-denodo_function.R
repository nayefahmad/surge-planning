

#*****************************************************
# Function to extract census from denodo 
#*****************************************************

# function definition: 
extract_census <- function(startdate_id, 
                           enddate_id, 
                           site = "Lions Gate Hospital", 
                           n_units = n_units_param, 
                           denodo_vw = vw_census){
      
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
            summarise(census = n())
      
      
}




# test the function: ------
library(beepr)

extract_census("20181212", 
               "20181213"); beep()
