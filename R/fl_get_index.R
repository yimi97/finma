#' Get time index of observations started and ended
#'
#' This function compute the time index of observations started and ended (when
#' the barriers are touched), used for k-fold CV and creating data partition.
#'
#' @param label_df A data.frame with at least two columns,
#'                 "first_touch": Time when the observation ended (i.e. when the
#'                 barriers are touched),
#'                 "label": An integer label for the observation,
#'                 and the index of label_df should be the time when the observation started
#' @return A data.frame of time index and label
#' @export
#'
#' @examples
#' label_df <- fl_get_label(apple, fl_simulate_events(apple))
#' fl_get_index(label_df)
#'
#' @author Yi Mi
fl_get_index <- function(label_df) {
  check <- c("first_touch", "label")
  df_col <- names(label_df)
  assert_that(not_empty(label_df) && (all(check %in% df_col)))

  n <- nrow(label_df)
  t0 <- as.Date(rownames(label_df), "%Y-%m-%d")
  first_touch <- as.Date(label_df$first_touch, "%Y-%m-%d")

  df <- data.frame(t0 = t0, first_touch = first_touch,
                   t0_index = integer(n), first_touch_index = integer(n),
                   label = label_df$label)

  t0_index <- rownames(df)
  df$t0_index <- as.numeric(t0_index)

  for (i in 1:nrow(df)) {
    df[i,"first_touch_index"] <- as.numeric(df$t0_index[t0==df[i, "first_touch"]])
  }

  var <- c("t0_index", "first_touch_index", "label")
  df <- df[,var]

  return(df)
}
