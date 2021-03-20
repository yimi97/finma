#' Simulate events
#'
#' This function simulates events to get the time stamp of vertical barriers
#' and the unit absolute return which is used to set horizontal barriers as
#' unit width. We get the simulate \code{trgt} using the function
#' \code{fl_daily_volatility()}.
#'
#' @param x A \code{zoo} time series object.
#' @param delta The time interval between day 0 and t1.
#' @param span Span days.
#'
#' @return A data frame of events.
#'         \code{t1}: the time stamp of vertical barriers.
#'         \code{trgt}: the unit absolute return used to set up horizontal
#'         barrier.
#'
#' @export
#'
#' @examples
#' fl_simulate_events(apple)
#'
fl_simulate_events <- function(x, delta = 15, span = 100) {
  assert_that(not_empty(x) && is.numeric(delta) &&
                delta > 0 && is.numeric(span) && span > 0)

  index_x <- zoo::index(x)
  events <- data.frame(side = rep(1, length(x)), row.names = index_x)
  t1 <- findInterval(index_x + delta, index_x, left.open = T)
  events$t1 <- index_x[t1]
  vol <- fl_daily_volatility(x, span)
  events <- tidyr::drop_na(merge(events, vol, by = 0, all = T))
  row.names(events) <- events$Row.names
  events$Row.names <- NULL
  names(events)[3] <- "trgt"
  return(events)
}
