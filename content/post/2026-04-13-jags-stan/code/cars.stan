data {
  int<lower=0> N;   // number of data items
  int<lower=0> K;   // number of predictors
  matrix[N, K] x;   // predictor matrix
  vector[N] y;      // outcome vector
}
parameters {
  real alpha;           // intercept
  vector[K] beta;       // coefficients for predictors
  real<lower=0> sigma;  // error scale
}
model {
  // alpha ~ normal(0, 1);  // prior
  // beta ~ normal(0, 1);   // prior
  y ~ normal(x * beta + alpha, sigma);  // likelihood
}
generated quantities {
  vector[N] log_lik; // pointwise log-likelihood for LOO
  vector[N] y_rep;   // replications from posterior predictive dist
  for (i in 1 : N) {
    real y_hat_i = alpha + x[i] * beta;
    log_lik[i] = normal_lpdf(y[i] | y_hat_i, sigma);
    y_rep[i] = normal_rng(y_hat_i, sigma);
  }
}
