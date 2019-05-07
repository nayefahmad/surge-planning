

#*****************************************************
# Function to extract admits from denodo 
#*****************************************************

# function definition: 
extract_admits <- function(startdate_id, 
                           enddate_id, 
                           site = "Lions Gate Hospital", 
                           n_units = n_units_param, 
                           denodo_vw = vw_adtc){
  
  # inputs: 
  # > startdate and enddate as integers
  # > denodo_view is the name of the table saved as a connection via dbplyr 
  
  # outputs: 
  # dataframe with dates and admission counts, by nursing unit
  
  denodo_vw %>% 
    filter(facility_name == !!(site),  # !! used to unquote the actual argument "site" 
           admission_date_id >= startdate_id, 
           admission_date_id <= enddate_id, 
           nursing_unit_cd_at_admit %in% n_units) %>% 
    
    select(admission_date_id, 
           patient_id, 
           nursing_unit_cd_at_admit, 
           facility_name) %>%  # show_query()
    
    collect() %>% 
    
    group_by(admission_date_id, 
             nursing_unit_cd_at_admit) %>%
    summarise(admits = n()) %>% 
    rename(date_id = admission_date_id, 
           nursing_unit_cd = nursing_unit_cd_at_admit) %>% 
    
    # display in long format: 
    gather(key = "metric",
           value = "value", 
           -c(date_id, nursing_unit_cd))
  
  
}




# test the function: ------
library(beepr)

admits <- extract_admits("20180501", 
                         "20181231"); beep()

admits %>% filter(nursing_unit_cd == "LGH 4E")