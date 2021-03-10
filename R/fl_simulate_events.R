#' Simulate events
#'
#' This function simulates events to get the time stamp of vertical barriers
#' and the unit absolute return which is used to set up horizontal barrier as
#' unit width. We get the simulate `trgt` using the function
#' fl_get_daily_volatility().
#'
#' @param x A time series data we want to simulate
#' @param delta_t1 The interval between day 0 and t1, which is 15 as default
#' @param span Span days
#'
#' @return A data frame of events with t1 and trgt
#'         "t1": The time stamp of vertical barriers
#'         "trgt": the unit absolute return used to set up horizontal barrier.
#' @export
#'
#' @examples
#' x <- apple
#' fl_simulate_events(x)
#'
#' @author Yi Mi
fl_simulate_events <- function(x, delta_t1=15, span=100) {
  assert_that(not_empty(x) && is.numeric(delta_t1) &&
                delta_t1 > 0 && is.numeric(span) && span > 0)

  index_x <- zoo::index(x)
  events <- data.frame(side = rep(1, length(x)), row.names = index_x)
  t1 <- findInterval(index_x + delta_t1, index_x, left.open = T)
  events$t1 <- index_x[t1]
  vol <- fl_get_daily_volatility(x, span)
  # vol <- simulate_daily_return(x)
  events <- tidyr::drop_na(merge(events, vol, by=0, all=T))
  row.names(events) <- events$Row.names
  events$Row.names <- NULL
  names(events)[3] <- "trgt"
  return(events)
}
