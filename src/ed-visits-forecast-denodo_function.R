#*****************************************************
# Function to produce ED visit forecast for given date range 
#*****************************************************

library(lubridate)

# import df with holidays specified: 
options(readr.default_locale=readr::locale(tz="America/Los_Angeles"))

holidays <- 
  read_csv(here::here("data", 
                      "2019-05-13_holidays-data-frame.csv")) %>% 
  mutate(ds = mdy(ds))



# function definition: 
edvisits_forecast <- function(startdate_id, 
                              enddate_id, 
                              past_years = 3,  # todo: change to 5?  
                              site = "Lions Gate Hospital", 
                              holidays_df = NULL, 
                              fcast_only = TRUE, 
                              changepoints_vec = NULL, 
                              trend_flexibility = 0.05,  # default set by prophet
                              save_plots = FALSE, 
                              denodo_vw = vw_census){
  
  # inputs: 
  # > start and end date_id: the date range for which to return forecast
  # > past_years: how many years historical data to pull for fitting the trend 
  # > n_unit: the nursing unit to forecast census for 
  # > fcast_only: if TRUE, return only the fcast, not the historical data pulled as well
  
  # outputs: 
  # > dataframe with columns: date_id, nursing_unit_cd, metric, value
  # > levels of "metric" field: predicted, prediction_lower, prediction_upper
  
  library(lubridate)
  library(stringr)
  
  
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
  edvisits <- extract_ed_visits(historical_start_id, 
                                historical_end_id) %>% 
    ungroup() %>%  # convert from grouped_df to df
    right_join(full_date_list)
  
  
  
  # set up data for prophet:  
  edvisits <- edvisits %>% 
    select(date, 
           value) %>% 
    rename(ds = date, 
           y = value)
  
  
  # fit prophet model: ------------------------------
  library(prophet)
  
  m <- prophet(edvisits, 
               holidays = holidays_df, 
               changepoints = changepoints_vec, 
               changepoint.prior.scale = trend_flexibility)
  
  future <- make_future_dataframe(m, 
                                  periods = horizon_param,
                                  freq = "day")  
  
  fcast <- predict(m, future)  # to be used for plotting below
  
  fcast_modified <- fcast %>%  # to be returned by the function
    select(ds, 
           yhat_lower, 
           yhat, 
           yhat_upper) %>% 
    
    rename(edvisits_lower_ci = yhat_lower, 
           edvisits_fcast = yhat, 
           edvisits_upper_ci = yhat_upper) %>% 
    
    # reformat result: 
    mutate(date_id = map_int(ds, 
                             function(x){
                               x %>% as.character() %>% 
                                 str_replace_all("-", "") %>% 
                                 as.integer()
                             })) %>% 
    select(date_id, ds, everything()) %>% 
    
    # return historical pull as well as fcast? 
    {if (fcast_only) {filter(., date_id >= startdate_id)
      } else {.}}
  
  # save forecast and plot components
  plot_fitted <- plot(m, fcast)
  plot_components <- prophet_plot_components(m, fcast)
  
  
  if (save_plots) {
    return(list(fcast_modified, 
                plot_fitted, 
                plot_components, 
                fcast))
  } else {
    return(fcast_modified)
  }
  
  
}




# test the function: ------
startdate_id <- "20190501"
enddate_id <- "20190527"

edvisits_actual <- extract_ed_visits(startdate_id,
                                     enddate_id)


edvisits_fcast <- edvisits_forecast(startdate_id,
                                    enddate_id,
                                    trend_flexibility = 0.05,
                                    save_plots = TRUE,
                                    holidays_df = holidays)

# str(edvisits_fcast)


# plot comparing actual with forecast: 
# edvisits_fcast %>%
#       ggplot(aes(x = ds,
#                  y = edvisits_fcast)) +
#       geom_ribbon(aes(x = ds,
#                       ymin = edvisits_lower_ci,
#                       ymax = edvisits_upper_ci),
#                   fill = "grey80",
#                   alpha = 0.5) +
#       geom_line(col = "skyblue") +
#       geom_point(col = "skyblue") +
# 
#       geom_line(data = edvisits_actual %>%
#                       bind_cols(edvisits_fcast %>% select(ds)),
#                 aes(x = ds,
#                     y = value),
#                 col = "blue") +
# 
#       theme_light() +
#       theme(panel.grid.minor = element_line(colour = "grey95"),
#               panel.grid.major = element_line(colour = "grey95"))


