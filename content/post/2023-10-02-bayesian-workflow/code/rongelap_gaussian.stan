data {
  int<lower=1> N;
  int<lower=1> D;
  array[N] vector[D] X;
  vector[N] y;
}
transformed data {
  real delta = 1e-9;
}
parameters {
  real alpha;
  real<lower=0> sigma;
  real<lower=0> phi;
}
transformed parameters {
  vector[N] mu = rep_vector(alpha, N);
  matrix[N, N] K = gp_exponential_cov(X, sigma, phi) + diag_matrix(rep_vector(delta, N));
  matrix[N, N] L_K = cholesky_decompose(K);
}
model {
  alpha ~ std_normal();
  sigma ~ inv_gamma(5, 5);
  phi ~ std_normal();

  y ~ multi_normal_cholesky(mu, L_K);
}
