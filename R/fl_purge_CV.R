#' Partition data for k-fold cross-validation with purging and embargo
#'
#' This function partitions time series data observations for k-fold
#' cross-validation with purging and embargo. Observations from the training
#' set are purged to prevent leakage from the training set to testing set.
#' Embargo is also used to reduce serial correlation.
#'
#' @param df A data frame with at least three columns.
#'           \code{t0_index}: the time index for the start observations.
#'           \code{first_touch_index}: the time index for the end observation
#'           when the barriers are touched.
#'           \code{label}: a numeric label for the observation.
#' @param purged A logical vector indicating whether to purge observations or
#'   not.
#' @param k A numeric vector indicating the number of folds.
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
#' fl_purge_cv(df)
#'
fl_purge_cv <- function(df, purged = TRUE, k = 5) {
  check <- c("t0_index", "first_touch_index", "label")
  df_col <- names(df)
  assert_that(not_empty(df) && (all(check %in% df_col)) &&
                is.flag(purged) && is.numeric(k) && k > 0)

  df <- df[, check]
  n <- nrow(df)
  num_each_fold <- floor(n / k)
  n_fold <- c(rep(num_each_fold, k - 1), n - num_each_fold * (k - 1))
  cumsum_fold <- c(0, cumsum(n_fold))

  out <- lapply(1:k, function(i) {
    test_index <-
      (cumsum_fold[i] + 1):cumsum_fold[i + 1] # index in i-th fold
    test_fold <- df[test_index, ]
    train_fold <- df[setdiff(1:n, test_index), ]

    if (purged) {
      # embargo h ~= 0.01T
      h <- 0.01 * n
      before_test <-
        min(test_fold$t0_index) # t_j0: min time index of test set
      after_test <-
        max(test_fold$first_touch_index) + h # t_j1 + h: max time index of test set + embargo
      train_fold <- subset(train_fold,
                           (first_touch_index < before_test) |
                             (t0_index > after_test))

      used_index <- c(rownames(test_fold), rownames(train_fold))
      purged <- df[setdiff(1:n, used_index), ]
      list(train = train_fold,
           test = test_fold,
           purged = purged)
    }
    else {
      list(train = train_fold, test = test_fold)
    }
  })
}
