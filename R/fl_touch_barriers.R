#' Get the time of the first barrier touch
#'
#' This function identifies the time when the first of three barriers (
#' horizontal-upper, horizontal-lower, vertical) is touched.
#'
#' @param x A \code{zoo} time series object.
#' @param events A data frame, with \code{t1} - the time stamp of vertical
#'   barrier, and \code{trgt} - the unit width of horizontal barriers.
#' @param lower_barrier A logical vector to apply a lower horizontal
#'   barrier or not.
#' @param upper_barrier A logical vector to apply a upper horizontal
#'   barrier or not.
#' @param lower_multiplier A multiplicative numeric quantity to set the width
#'   of the lower barrier.
#' @param upper_multiplier A multiplicative numeric quantity to set the width
#'   of the upper barrier.
#'
#' @return A data frame with the first touch of three barriers.
#' @export
#' @import zoo
#' @useDynLib finma
#' @importFrom assertthat assert_that not_empty is.flag
#'
#' @examples
#' fl_touch_barriers(apple, fl_simulate_events(apple))
#'
fl_touch_barriers <- function(x,
                              events,
                              lower_barrier = TRUE,
                              upper_barrier = TRUE,
                              lower_multiplier = 1,
                              upper_multiplier = 1) {
  check <- c("t1", "trgt")
  events_col <- names(events)
  assert_that(
    not_empty(x) && not_empty(events) &&
      (all(check %in% events_col)) &&
      is.flag(lower_barrier) && is.flag(upper_barrier) &&
      is.numeric(lower_multiplier) &&
      lower_multiplier > 0 &&
      is.numeric(upper_multiplier) &&
      upper_multiplier > 0
  )

  n <- length(x)
  n_events <- nrow(events)
  index_events <- row.names(events)

  if (lower_barrier) {
    lower <- -lower_multiplier * events$trgt
  } else {
    lower <- rep(-Inf, n_events)
  }

  if (upper_barrier) {
    upper <- upper_multiplier * events$trgt
  } else {
    upper <- rep(Inf, n_events)
  }
  events$t1 <- tidyr::replace_na(events$t1, zoo::index(x)[n])

  df <- apply_ptsl_helper(
    value = x,
    date = as.character(zoo::index(x)),
    start = as.character(row.names(events)),
    end = as.character(events$t1),
    side = events$side,
    lower,
    upper
  )

  df[df == ""] <- NA
  df$t1 <- events$t1
  row.names(df) <- index_events
  return(df)
}
