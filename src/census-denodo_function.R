

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
      
      denodo_vw %>% 
            filter(facility_name == !!(site),  # !! used to unquote the actual argument "site" 
                   census_date_id >= startdate_id, 
                   census_date_id <= enddate_id, 
                   nursing_unit_short_desc_at_census %in% n_units) %>% 
            
            select(census_date_id, 
                   patient_id, 
                   nursing_unit_short_desc_at_census, 
                   facility_name) %>%  # show_query()
            
            collect() %>% 
             
            group_by(census_date_id, 
                     nursing_unit_short_desc_at_census) %>%
            summarise(census = n()) %>% 
            rename(date_id = census_date_id) %>% 
            
            # display in long format: 
            gather(key = "metric",
                   value = "value", 
                   -c(date_id, nursing_unit_short_desc_at_census)) %>% 
            ungroup
      
      
}




# test the function: ------
# library(beepr)

census <- extract_census("20181212",
                         "20181213") 
