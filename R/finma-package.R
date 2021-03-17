#' @title The global variables used for this package.
#'
#' Inside get_index function, their are two variable used as global,
#' "first_touch_index" and "t0_index"
#'
#' @name globalVariables
#'
#' @useDynLib finma, .registration = TRUE
#' @importFrom Rcpp sourceCpp
#' @author Yi Mi
#' @references Prado, M. L. (2018). Advances in financial machine learning. New Jersey: Wiley.
NULL
utils::globalVariables(c("first_touch_index", "t0_index", "apply_ptsl_helper"))
