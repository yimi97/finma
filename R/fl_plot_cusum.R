#' Visualize the symmetric CUSUM filter result
#'
#' This function displays the symmetric CUSUM filter result by plotting the
#' asset's price and points that identify the filtered data.
#'
#' @param x A \code{zoo} time series object of daily stock prices.
#' @param cusum A filtered zoo time series object using CUSUM filtering.
#'
#' @return A \code{plot} object
#' @export
#'
#' @examples
#' cusum <- fl_cusum_filter(apple, 10)
#' fl_plot_cusum(apple, cusum)
#'
fl_plot_cusum <- function(x, cusum) {
  assert_that(not_empty(x) && not_empty(cusum))

  plot(
    x,
    main = "CUSUM sampling of a price series",
    xlab = "Time",
    ylab = "Price",
    col = "gray"
  )
  graphics::points(cusum, col = "red")
}
