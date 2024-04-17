#include <Rcpp.h>

// [[Rcpp::export]]
int fibonacci(const int x) {
  if (x < 2) return(x);
  return (fibonacci(x - 1)) + fibonacci(x - 2);
}
