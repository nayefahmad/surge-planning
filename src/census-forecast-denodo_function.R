

#*****************************************************
# Function to produce census forecast for given date range 
#*****************************************************

# library(lubridate)

# function definition: 
census_forecast <- function(startdate_id, 
                            enddate_id, 
                            past_years = 3, 
                            site = "Lions Gate Hospital", 
                            n_unit = n_unit_param, 
                            denodo_vw = vw_census){
      
      # inputs: 
      # > start and end date_id: the date range for which to return forecast
      # > paste_years: how many years historical data to pull for fitting the trend 
      # > n_unit: the nursing unit to forecast census for 
      
      # outputs: 
      # > dataframe with columns: date_id, nursing_unit_cd, metric, value
      # > levels of "metric" field: predicted, prediction_lower, prediction_upper
      
      library(lubridate)
      library(stringr)
      

      # check whether function to pull census from denodo has been loaded: 
      stopifnot(exists("extract_census"))
      
      
      # historical data range: 
      historical_start <- ymd(startdate_id) -1 - years(past_years) %>% print
      historical_end <- ymd(startdate_id) -1 %>% print
      
      historical_start_id <- 
            historical_start %>% 
            as.character( ) %>% 
            str_replace_all("-", "")
      
      historical_end_id <- 
            historical_end %>% 
            as.character( ) %>% 
            str_replace_all("-", "")
      
      
      full_date_list <- 
            data.frame(date = seq(historical_start, 
                                  historical_end, 
                                  by = "1 day")) %>% 
            mutate(date_id = map(date, 
                                 function(x){
                                       x %>% as.character() %>% 
                                             str_replace_all("-", "")
                                             
                                 }))
            
      
      
      # pull historical data: 
      census <- extract_census(historical_start_id, 
                               historical_end_id, 
                               n_units = n_unit_param)
      
      
      
      
      
}




# test the function: ------
census_forecast("20181201", 
                "20190501", 
                "LGH 6E")
