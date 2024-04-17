// [[Rcpp::depends(BH)]]

#include <Rcpp.h>
#include <boost/integer/common_factor.hpp>
#include <boost/integer/common_factor_ct.hpp>
#include <boost/integer/common_factor_rt.hpp>

// [[Rcpp::export]]
int computeGCD(int a, int b) {
    return boost::integer::gcd(a, b);
}
