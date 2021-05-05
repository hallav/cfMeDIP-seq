//LR with RHS prior model implementation from Piironen & Vehtari (2017). Sparsity information and regularization in the horseshoe and other shrinkage priors. Electronic Journal of Statistics, 11(2), 5018-5051.
data {
  int<lower=0> n;
  int<lower=0> d;
  int<lower=0,upper=1> y[n];
  matrix[n,d] x;
  real<lower=0> scale_icept;
  real<lower=0> scale_global;
  real<lower=1> nu_global;
  real<lower=1> nu_local;
  real<lower=0> slab_scale;
  real<lower=0> slab_df;

}
parameters {
  real beta0;
  vector[d] z;
  real<lower=0> aux1_global;
  real<lower=0> aux2_global;
  vector<lower=0>[d] aux1_local;
  vector<lower=0>[d] aux2_local;
  real<lower=0> caux;

}

transformed parameters {
  real<lower=0> tau;
  vector<lower=0>[d] lambda;
  vector<lower=0>[d] lambda_tilde;
  real<lower=0> c;
  vector[d] beta;
  vector[n] f;
  lambda = aux1_local .* sqrt(aux2_local);
  tau = aux1_global * sqrt(aux2_global) * scale_global;
  c = slab_scale * sqrt(caux);
  lambda_tilde = sqrt( c^2 * square(lambda) ./ (c^2 + tau^2*square(lambda)) );
  beta = z .* lambda_tilde*tau;
  f = beta0 + x*beta;

}

model {
  z ~ normal(0, 1);
  aux1_local ~ normal(0,1);
  aux2_local ~ inv_gamma(0.5*nu_local, 0.5*nu_local);
  aux1_global ~ normal(0, 1);
  aux2_global ~ inv_gamma(0.5*nu_global, 0.5*nu_global); 
  caux ~ inv_gamma(0.5*slab_df, 0.5*slab_df);
  beta0 ~ normal(0, scale_icept);
  y ~ bernoulli_logit(f);

}

