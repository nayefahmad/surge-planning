

#*****************************************************
# Function to extract census from denodo 
#*****************************************************

# function definition: 
extract_census <- function(startdate_id, 
                           enddate_id, 
                           site = "Lions Gate Hospital", 
                           denodo_vw = vw_census){
      
      
      
      
      # inputs: 
      # > startdate and enddate as integers
      # > denodo_view is the name of the table saved as a connection via dbplyr 
      
      # outputs: 
      # dataframe with census dates and census counts
      
      vw_census %>% 
            filter(facility_name == !!(site),  # !! used to unquote the actual argument "site" 
                   census_date_id >= startdate_id, 
                   census_date_id <= enddate_id) %>% 
            
            select(census_date_id, 
                   patient_id, 
                   facility_name) %>%  # show_query()
            
            collect() %>% 
             
            group_by(census_date_id) %>%
            summarise(census = n())
      
      
}




# test the function: ------
extract_census("20181212", 
               "20181212")
