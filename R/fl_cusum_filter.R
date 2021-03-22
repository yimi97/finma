#' Apply a symmetric CUSUM filter
#'
#' This function applies a symmetric CUSUM filter, which is a quality-control
#' method, designed to detect a shift in the mean value of a measured quantity
#' away from a target value.
#'
#' @param x A \code{zoo} time series object to filter.
#' @param h A numeric vector of length one for the threshold (the filter size).
#' @param just_dates A logical vector of length one. A value of \code{TRUE}
#'   returns a vector of dates, otherwise a \code{zoo} series is returned.
#'
#' @return A vector of dates or a \code{zoo} time series object.
#' @export
#'
#' @importFrom assertthat assert_that not_empty is.flag
#'
#' @examples
#' fl_cusum_filter(apple, 10)
#'
fl_cusum_filter <- function(x, h, just_dates = FALSE) {
  assert_that(not_empty(x) &&
                is.numeric(h) && h > 0 && is.flag(just_dates))

  t_events <- c()
  s_pos <- 0
  s_neg <- 0
  diff <- diff(x)
  diff_index <- zoo::index(diff)

  sapply(1:length(diff),
         function(i)
         {
           s_pos <<- max(0, s_pos + diff[i])
           s_neg <<- min(0, s_neg + diff[i])

           if (s_neg < -h) {
             s_neg <<- 0
             t_events <<- c(t_events, diff_index[i])
           }
           else if (s_pos > h) {
             s_pos <<- 0
             t_events <<- c(t_events, diff_index[i])
           }
         })

  if (just_dates) {
    return(as.Date(t_events))
  }
  return(x[as.Date(t_events)])
}
