data {
  int<lower=1> N;
  int<lower=1> D;
  array[N] vector[D] X;
  array[N] int<lower = 0> y;
  vector[N] offsets;
}
transformed data {
  real delta = 1e-12;
  vector[N] log_offsets = log(offsets);
}
parameters {
  real alpha;
  real<lower=0> sigma;
  real<lower=0> phi;
  vector[N] f;
}
transformed parameters {
  vector[N] mu = rep_vector(alpha, N);
  matrix[N, N] K = gp_exponential_cov(X, sigma, phi) + diag_matrix(rep_vector(delta, N));
  matrix[N, N] L_K = cholesky_decompose(K);
}
model {
  alpha ~ std_normal();
  sigma ~ std_normal();
  phi ~ normal(2, 2.5);
  
  f ~ multi_normal_cholesky(mu, L_K);
  y ~ poisson_log(log_offsets + f);
}
generated quantities {
  vector[N] RR = log_offsets + f;
  vector[N] log_lik;                   // Log likelihood for each location
  vector[N] ypred;
  
  for (n in 1:N){
    log_lik[n] = poisson_log_lpmf(y[n] | RR[n]);
    ypred[n]   = poisson_log_rng(RR[n]);   
  }
}
