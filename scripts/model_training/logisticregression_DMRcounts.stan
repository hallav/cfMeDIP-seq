//Logistic regression model with recommended prior from Gelman et al.(2008). A weakly informative default prior distribution for logistic and other regression models. Annals of applied Statistics, 2(4), 1360-1383.
data {
  int<lower=0> n;
  int<lower=0,upper=1> y[n];
  matrix[n,2] x;
  real<lower=0> scale_icept;
  real<lower=0> scale_coeff;

}
parameters {
  real alpha;
  vector[2] beta;

}

transformed parameters {
  vector[n] f;
  f = alpha + x*beta;

}

model {
  beta ~ cauchy(0, scale_coeff);
  alpha ~ cauchy(0, scale_icept);
  y ~ bernoulli_logit(f);

}

