#' k-fold CV with purging and embargo
#'
#' This function implements purged k-fold CV to purge from training set all
#' observations whose labels overlapped in time with those labels included in
#' the testing set to reduce leakage, which is "purging". In addition, it also
#' eliminates from the training set observations that immediately follow an
#' observation in the testing set to reduce serial correlation, which is
#' "embargo".
#'
#' @param df A data.frame with at least three columns,
#'           "t0_index": Time index for the observation started,
#'           "first_touch_index": Time index for the observation ended,
#'           i.e. when the barriers are touched
#'           "label": Integer label for the observation
#' @param purged A Boolean indicating whether using purging and embargo or not
#' @param k An integer for k-fold
#'
#' @return If purged is true, return a list of k-fold training, test and purged set,
#'         If purged is false, return a list of k-fold training and test set
#' @export
#'
#' @examples
#' label_df <- fl_get_label(apple, fl_simulate_events(apple))
#' df <- fl_label_index(label_df)
#' fl_purge_cv(df)
#'
#' @author Yi Mi
fl_purge_cv <- function(df, purged = TRUE, k = 5) {
  check <- c("t0_index", "first_touch_index", "label")
  df_col <- names(df)
  assert_that(not_empty(df) &&(all(check %in% df_col)) &&
                is.flag(purged) && is.numeric(k) && k > 0)

  df <- df[,check]
  n <- nrow(df)
  num_each_fold <- floor(n/k)
  n_fold <- c(rep(num_each_fold, k-1), n - num_each_fold*(k-1))
  cumsum_fold <- c(0, cumsum(n_fold))

  out <- lapply(1:k, function(i){
    test_index <- (cumsum_fold[i]+1):cumsum_fold[i+1] # index in i-th fold
    test_fold <- df[test_index,]
    train_fold <- df[setdiff(1:n, test_index),]

    if (purged) {
      # embargo h ~= 0.01T
      h <- 0.01*n
      before_test <- min(test_fold$t0_index) # t_j0: min time index of test set
      after_test <- max(test_fold$first_touch_index) + h # t_j1 + h: max time index of test set + embargo
      train_fold <- subset(train_fold,
                           (first_touch_index < before_test) | (t0_index > after_test))

      used_index <- c(rownames(test_fold), rownames(train_fold))
      purged <- df[setdiff(1:n, used_index),]
      list(train = train_fold, test = test_fold, purged = purged)
    }
    else {
      list(train = train_fold, test = test_fold)
    }
  })
}
