#' Triple-barrier labeling method
#'
#' This function identifies which of the three barriers (
#' horizontal-upper, horizontal-lower, vertical) is touched first and gives the
#' label of -1, 0, or 1.
#'
#' @param x A \code{zoo} time series object
#' @param events A data frame of events, can be simulated by calling function
#'               simulate_events.
#'               \code{t1}: a series of time stamp of the vertical barrier.
#'               \code{trgt}: the unit absolute return used to set up horizontal
#'               barrier.
#' @param vertial_touch_label An argument with two options: "sign" and "zero".
#'   For "sign", the label is decided by the sign of the return. For "zero",
#'   if vertical barrier is touched first, then the label is set to 0.
#'
#' @return A data frame of events with the first barrier touch label
#' @export
#'
#' @examples
#' fl_get_label(apple, fl_simulate_events(apple))
#'
fl_get_label <- function(x, events, vertial_touch_label = "sign") {
  option <- c("sign", "zero")
  check <- c("t1", "trgt")
  events_col <- names(events)
  assert_that(not_empty(x) && not_empty(events) &&
                (all(check %in% events_col)) &&
                vertial_touch_label %in% option)

  # get first touch
  barrier_touch <- fl_touch_barriers(x, events)
  first_touch <-
    apply(barrier_touch, 1, function(x)
      min(x, na.rm = T))
  all_touch <- cbind(barrier_touch, first_touch)

  t0 <- row.names(all_touch)
  first_touch <- all_touch$first_touch

  # get price
  x_df <- data.frame(x)
  t0_price <- x_df[as.character(t0), ]
  first_touch_price <- x_df[as.character(first_touch), ]
  return <- round(first_touch_price / t0_price, 5) - 1
  label <- ifelse(return < 0,-1, 1)
  label[return == 0] <- 0

  out <-
    cbind(all_touch, t0_price, first_touch_price, return, label)

  # vertial_touch_label can also be "sign"
  if (vertial_touch_label == "zero") {
    out$label[out$t1 == out$first_touch] <- 0
  }

  return(out)
}
