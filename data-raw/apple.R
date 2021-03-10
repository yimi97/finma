## code to prepare `apple` dataset goes here
library(tidyverse)
library(Quandl)
'
raw <- Quandl("XNAS/AAPL", api_key="h1c5XvQzq5k18ybK3hRy")
apple <- raw %>% select(Date, Close)
apple <-  zoo(apple$Close, order.by = as.Date(apple$Date))
'
xx.Date <- as.Date("2003-02-01") + 1:10000
apple <- zoo(rlnorm(10000), xx.Date)

usethis::use_data(apple, overwrite = TRUE)
