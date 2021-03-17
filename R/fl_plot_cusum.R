#' Plot symmetric CUSUM filter result
#'
#' This function plots symmetric CUSUM filter result by plotting the line of
#' stock price with dots of filtered data.
#'
#' @param x A zoo time series data of daily stock price in zoo format
#' @param cusum Filtered x using CUSUM
#'
#' @return The function prints the plot
#' @export
#'
#' @examples
#' filtered_x <- fl_cusum_filter(apple, 10)
#' fl_plot_cusum(apple, filtered_x)
#'
#' @author Yi Mi
fl_plot_cusum <- function(x, cusum) {
  assert_that(not_empty(x) && not_empty(cusum))

  plot(x,
       main="CUSUM sampling of a price series",
       xlab="Time",
       ylab="Price",
       col="gray")
  graphics::points(cusum, col="red")
}
