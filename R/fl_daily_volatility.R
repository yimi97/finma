#' Compute an asset's daily price volatility
#'
#' This function computes the daily price volatility at intraday estimation
#' points, applying a span of days to an exponentially weighted moving standard
#' deviation.
#'
#' @param x A \code{zoo} time series object
#' @param span A numeric vector of days
#'
#' @return A \code{zoo} time series object of daily price volatilities
#' @export
#'
#' @examples
#' fl_daily_volatility(apple, 100)
#'
fl_daily_volatility <- function(x, span = 100) {
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
