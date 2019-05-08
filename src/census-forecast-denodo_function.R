

#*****************************************************
# Function to produce census forecast for given date range 
#*****************************************************

# library(lubridate)
# library(stringr)
# library(tidyverse)

# function definition: 
census_forecast <- function(startdate_id, 
                            enddate_id, 
                            past_years = 1,  # todo: change to 5?  
                            site = "Lions Gate Hospital", 
                            n_unit, 
                            denodo_vw = vw_census){
      
      # inputs: 
      # > start and end date_id: the date range for which to return forecast
      # > paste_years: how many years historical data to pull for fitting the trend 
      # > n_unit: the nursing unit to forecast census for 
      
      # outputs: 
      # > dataframe with columns: date_id, nursing_unit_cd, metric, value
      # > levels of "metric" field: predicted, prediction_lower, prediction_upper
      

      # check whether function to pull census from denodo has been loaded: 
      stopifnot(exists("extract_census"))
      
      
      # historical data range: 
      historical_start <- lubridate::ymd(startdate_id) -1 - years(past_years)
      historical_end <- lubridate::ymd(startdate_id) -1 
      
      print(c(historical_start, 
              historical_end))
      
      # start and end as date_ids: 
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
            mutate(date_id = map_int(date, 
                                     function(x){
                                           x %>% as.character() %>% 
                                                 str_replace_all("-", "") %>% 
                                                 as.integer()
                                    }
                              ))
      
      
      # pull historical data: 
      census <- extract_census(historical_start_id, 
                               historical_end_id, 
                               n_units = n_unit) %>% 
            ungroup() %>%  # convert from grouped_df to df
            right_join(full_date_list)
      
      # todo: join on full date list: 
      
      
      return(census)
      
}




# test the function: ------
census_fcast <- census_forecast("20181201", 
                                "20190501", 
                                n_unit = "LGH 6E")

str(census_fcast)
