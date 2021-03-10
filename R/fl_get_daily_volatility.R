#' Compute daily volatility
#'
#' This function computes daily volatility at intraday estimation points,
#' applying a span of `span` days to an exponentially weighted moving standard
#' deviation. We can use the output of this function to set default profit
#' taking and stop-loss limits.
#'
#' @param x A time series data we want to compute daily volatility
#' @param span An integer of span days
#'
#' @return A time series data of daily volatility
#' @export
#'
#' @examples
#' x <- apple
#' fl_get_daily_volatility(x, 100)
#'
#' @author Yi Mi
fl_get_daily_volatility <- function(x, span = 100) {
  assert_that(not_empty(x) && is.numeric(span) && span > 0)

  index_x <- zoo::index(x)
  use_index <- findInterval(index_x - 1, index_x, left.open = T)
  use_index <- use_index[use_index > 0]

  prev_index <- data.frame(Date = index_x[use_index],
                           row.names = index_x[length(x)-length(use_index)+1:length(use_index)])
  x_df <- data.frame(x)
  prev_price <- x_df[as.character(prev_index$Date),]
  ret <- x[as.Date(row.names(prev_index))] / prev_price - 1

  # exponentially weighted moving standard deviation
  ewmsd <- function(x, alpha) {
    n <- length(x)
    sapply(
      1:n,
      function(i, x, alpha) {
        y <- x[1:i]
        m <- length(y)
        weights <- (1 - alpha)^((m - 1):0)
        ewma <- sum(weights * y) / sum(weights)
        bias <- sum(weights)^2 / (sum(weights)^2 - sum(weights^2))
        ewmsd <- sqrt(bias * sum(weights * (y - ewma)^2) / sum(weights))
      },
      x=x,
      alpha=alpha
    )
  }

  vol <- zoo::zoo(ewmsd(ret, 2/(span + 1)), order.by = zoo::index(ret))
  return(vol)
}
