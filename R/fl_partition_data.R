#' Create data partition
#'
#' This function divides the data into a training set and a test set,
#' the first 80% is the training set, and the last 20% is the test set.
#'
#' @param df A data.frame with at least three columns,
#'           "t0_index": Time index for the observation started,
#'           "first_touch_index": Time index for the observation ended,
#'           i.e. when the barriers are touched
#'           "label": Integer label for the observation
#' @param purged A Boolean indicating whether using purging and embargo or not
#' @param p The percentage of training set
#'
#' @return If purged is true, return a list of k-fold training, test and purged sets,
#'         If purged is false, return a list of k-fold training and test sets
#' @export
#'
#' @examples
#' label_df <- fl_get_label(apple, fl_simulate_events(apple))
#' df <- fl_label_index(label_df)
#' fl_partition_data(df)
#'
#' @author Yi Mi
fl_partition_data <- function(df, purged = TRUE, p = 0.8) {
  check <- c("t0_index", "first_touch_index", "label")
  df_col <- names(df)
  assert_that(not_empty(df) && (all(check %in% df_col)) && is.flag(purged) &&
                is.numeric(p) && p > 0 && p < 1)

  df <- df[,check]
  n <- nrow(df)
  test_index <- (floor((1-p)*n)*4 + 1):n
  test_fold <- df[test_index,]
  train_fold <- df[setdiff(1:n, test_index),]

  if (purged) {
    h <- 0.01*n
    before_test <- min(test_fold$t0_index)
    after_test <- max(test_fold$first_touch_index) + h
    train_fold <- subset(train_fold,
                         (first_touch_index < before_test) | (t0_index > after_test))

    used_index <- c(rownames(test_fold), rownames(train_fold))
    purged <- df[setdiff(1:n, used_index),]
    out <- list(train = train_fold, test = test_fold, purged = purged)
  }
  else {
    out <- list(train = train_fold, test = test_fold)
  }
  return(out)
}
