#' Partition time series data for training and testing
#'
#' This function divides the data into train and test sets. The first 80% is
#' observations are assigned to the training set; the last 20% are assigned to
#' the testing set.
#'
#' @param df A data frame with at least three columns.
#'           \code{t0_index}: the time index for the start observations.
#'           \code{first_touch_index}: the time index for the end observation
#'           when the barriers are touched.
#'           \code{label}: a numeric label for the observation.
#' @param purged A logical vector indicating whether to purge observations or
#'   not.
#' @param p The percentage of observations allocated to the training set.
#'
#' @return If \code{purged} is \code{TRUE}, return a list of k-fold training,
#'   test and purged sets. If \code{purged} is \code{FALSE}, return a list of
#'   k-fold training and test sets.
#'
#' @export
#'
#' @examples
#' label_df <- fl_get_label(apple, fl_simulate_events(apple))
#' df <- fl_label_index(label_df)
#' fl_partition_data(df)
#'
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
