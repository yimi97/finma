#' Apply symmetric CUSUM filter
#'
#' This function apply symmetric CUSUM filter, which is a quality-control
#' method, designed to detect a shift in the mean value of a measured quantity
#' away from a detect value.
#'
#' @param x A zoo time series data we with to filter
#' @param h An integer of the threshold (the filter size)
#' @param just_dates A Boolean, indicating if returning simply a vector of dates
#' or a zoo time series data
#'
#' @return A vector of dates or a zoo time series data
#' @export
#'
#' @importFrom assertthat assert_that not_empty is.flag
#'
#' @examples
#' fl_cusum_filter(apple, 10)
#'
#' @author Yi Mi
fl_cusum_filter <- function(x, h, just_dates = F){
  assert_that(not_empty(x) && is.numeric(h) && h > 0 && is.flag(just_dates))

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

           if(s_neg < -h) {
             s_neg <<- 0
             t_events <<- c(t_events, diff_index[i])
           }
           else if(s_pos > h) {
             s_pos <<- 0
             t_events <<- c(t_events, diff_index[i])
           }
         }
  )

  if (just_dates){
    return(as.Date(t_events))
  }
  return(x[as.Date(t_events)])
}
