// [[Rcpp::depends(BH)]]

#include <Rcpp.h>
#include <boost/integer/common_factor.hpp>
#include <boost/integer/common_factor_ct.hpp>
#include <boost/integer/common_factor_rt.hpp>

// [[Rcpp::export]]
int computeLCM(int a, int b) {
  return boost::integer::lcm(a, b);
}
