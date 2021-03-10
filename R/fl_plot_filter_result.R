#' Plot symmetric CUSUM filter result
#'
#' This function plots symmetric CUSUM filter result by plotting the line of
#' stock price with dots of filtered data.
#'
#' @param x A time series data of daily stock price in zoo format
#' @param filtered_x Filtered x using CUSUM
#'
#' @return The function prints the plot
#' @export
#'
#' @examples
#' x <- apple
#' filtered_x <- fl_filter_symmetric_cusum(x, 10)
#' fl_plot_filter_result(x, filtered_x)
#'
#' @author Yi Mi
fl_plot_filter_result <- function(x, filtered_x) {
  assert_that(not_empty(x) && not_empty(filtered_x))

  plot(x,
       main="CUSUM sampling of a price series",
       xlab="Time",
       ylab="Price",
       col="gray")
  graphics::points(filtered_x, col="red")
}
