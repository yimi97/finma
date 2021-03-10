#include <Rcpp.h>
using namespace Rcpp;

// This is a simple example of exporting a C++ function to R. You can
// source this function into an R session using the Rcpp::sourceCpp
// function (or via the Source button on the editor toolbar). Learn
// more about Rcpp at:
//
//   http://www.rcpp.org/
//   http://adv-r.had.co.nz/Rcpp.html
//   http://gallery.rcpp.org/
//

// [[Rcpp::export]]
DataFrame apply_ptsl_helper(NumericVector value, std::vector<std::string> date, std::vector<std::string> start,
                 std::vector<std::string> end, NumericVector side, NumericVector lower, NumericVector upper) {
  std::unordered_map<std::string, std::vector<double>> events; // date : {side, lower, upper}
  std::unordered_map<std::string, int> date_map; // date : index
  for (int i = 0; i < date.size(); ++i) {
    date_map[date[i]] = i;
  }
  for (int i = 0; i < start.size(); ++i) {
    events[start[i]] = std::vector<double>{side[i], lower[i], upper[i]};
  }

  std::vector<int> min_lower_index(start.size(), -1);
  std::vector<int> min_upper_index(start.size(), -1);
  std::vector<std::string> min_lower_date(start.size());
  std::vector<std::string> min_upper_date(start.size());
  for (int i = 0; i < start.size(); ++i) {
    int start_index = date_map[start[i]];
    int end_index = date_map[end[i]];
    double start_value = value[start_index];
    std::vector<double> temp = events[start[i]]; // side=temp[0],lower=temp[1],upper=temp[2]

    for (int j = start_index; j <= end_index; ++j) {
      double x = ((value[j] / start_value) - 1) * temp[0];
      if (min_lower_index[i] == -1 && x <= temp[1]) {
        min_lower_index[i] = j;
      }
      if (min_upper_index[i] == -1 && x >= temp[2]) {
        min_upper_index[i] = j;
      }
      if (min_lower_index[i] != -1 && min_upper_index[i] != -1) {
        break;
      }
    }
    min_lower_date[i] = min_lower_index[i] == -1 ? "" : date[min_lower_index[i]];
    min_upper_date[i] = min_upper_index[i] == -1 ? "" : date[min_upper_index[i]];
  }

  DataFrame df = DataFrame::create(Named("lower") = min_lower_date,
                                   Named("upper") = min_upper_date);
  return df;
}

