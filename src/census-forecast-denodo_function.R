

#*****************************************************
# Function to produce census forecast for given date range 
#*****************************************************

# library(lubridate)
# library(stringr)
# library(tidyverse)

# function definition: 
census_forecast <- function(startdate_id, 
                            enddate_id, 
                            past_years = 3,  # todo: change to 5?  
                            site = "Lions Gate Hospital", 
                            n_unit, 
                            denodo_vw = vw_census){
      
      # inputs: 
      # > start and end date_id: the date range for which to return forecast
      # > past_years: how many years historical data to pull for fitting the trend 
      # > n_unit: the nursing unit to forecast census for 
      
      # outputs: 
      # > dataframe with columns: date_id, nursing_unit_cd, metric, value
      # > levels of "metric" field: predicted, prediction_lower, prediction_upper
      

      # check whether function to pull census from denodo has been loaded: 
      stopifnot(exists("extract_census"))
      
      
      # historical data range: --------
      historical_start <- lubridate::ymd(startdate_id) -1 - years(past_years)
      historical_end <- lubridate::ymd(startdate_id) -1 
      
      # start and end as date_ids: 
      historical_start_id <- 
            historical_start %>% 
            as.character( ) %>% 
            str_replace_all("-", "")
      
      historical_end_id <- 
            historical_end %>% 
            as.character( ) %>% 
            str_replace_all("-", "")
      
      
      # full date list to join on, in case dates missing in census: 
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
      
      
      # horizon to forecast: ------------
      horizon_param <- difftime(ymd(enddate_id),
                                ymd(startdate_id)) %>% 
            as.integer() + 1
      
      # print(list(historical_start, 
      #            historical_end, 
      #            horizon_param))
      
      
      # pull historical data from denodo, using extract_census( ) function: 
      census <- extract_census(historical_start_id, 
                               historical_end_id, 
                               n_units = n_unit) %>% 
            ungroup() %>%  # convert from grouped_df to df
            right_join(full_date_list)
      
      
      
      # set up data for prophet:  
      census <- census %>% 
            select(date, 
                   value) %>% 
            rename(ds = date, 
                   y = value)
      
      
      # fit prophet model: 
      library(prophet)
      
      m <- prophet(census)
      
      future <- make_future_dataframe(m, 
                                      periods = horizon_param,
                                      freq = "day")  # 20 years, in months
      # print(future)
      
      fcast <- predict(m, future) %>% 
            select(ds, 
                   yhat_lower, 
                   yhat, 
                   yhat_upper) %>% 
            
            # reformat result: 
            mutate(date_id = map_int(ds, 
                                     function(x){
                                           x %>% as.character() %>% 
                                                 str_replace_all("-", "") %>% 
                                                 as.integer()
                                     })) %>% 
            select(date_id, ds, everything()) 
            # select(-ds) # %>% 
            # gather(key = "metric", 
            #        value = "value", 
            #        -date_id)
      
      # plot fcast: 
      plot(m, predict(m, future))
      
      # plot components: 
      prophet_plot_components(m, predict(m, future)) 
      
      return(fcast)
      
}




# test the function: ------
census_fcast <- census_forecast("20190215", 
                                "20190219", 
                                n_unit = "LGH 4W")

# str(census_fcast)
tail(census_fcast, 10)  # %>% write.table(file = "clipboard", sep = "\t", row.names = FALSE)

census_fcast %>% 
      ggplot(aes(x = ds, 
                 y = yhat)) + 
      geom_ribbon(data = slice(census_fcast, 1098:1104), 
                  aes(x = ds, 
                      ymin = yhat_lower, 
                      ymax = yhat_upper), 
                  fill = "blue") +
      geom_line() 
      
