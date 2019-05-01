Testing asymptotic variance estimation
================
dagniel
2019-05-01

``` r
library(knitr)
opts_chunk$set(warning = FALSE, message = FALSE, cache = FALSE, fig.width = 7, fig.height = 7)
```

``` r
library(tidyverse)
library(here)
library(synthate)
```

Here we'll test on a small scale whether we can estimate the asymptotic variance that we've derived. We'll use a toy simulation where the estimators are truly multivariate normal. We'll start with 5 unbiased estimators that are indpendent normals, with variance 10/*n*.

The question we'll answer here is: if we use plug-in estimators, and simulate the distribution of *J*, do we get close to the known theoretical values.

``` r
k <- 5
n <- 100
set.seed(0)
theta <- c(0, runif(k-1))
Sigma <- 10*diag(k)/n

d <- theta[-1]
V_0 <- Sigma[1,1]
V <- Sigma[-1,-1]
C <- Sigma[-1,1]
P <- V_0 - C
T <- V_0 + V - (matrix(1,nrow = k-1) %*% matrix(C, ncol = k-1)) - 
  (matrix(C,nrow = k-1) %*% matrix(1, ncol = k-1))
J <- mvnfast::rmvn(1000, mu = d, sigma = T)
K <- apply(J, 1, function(j) {
  (t(P) %*% solve(T) %*% j %*% t(j) %*% solve(T) %*% j) /
  (1 + t(j) %*% solve(T) %*% j)
})
E_K <- mean(K)
V_K <- var(K)
E_K2 <- mean(K^2)
rho <- E_K/(t(P) %*% solve(T) %*% d)
lambda <- E_K2/(t(P) %*% solve(T) %*% (T + d %*% t(d)) %*% solve(T) %*% P)

mse_G <- V_0 + (lambda - 1) * t(P) %*% solve(T) %*% P + (t(P) %*% solve(T) %*% d)^2 * (2*(1-rho) - 1 + lambda)

sim_l <- map(1:1000, function(i) {
  thetahat <- mvnfast::rmvn(1, mu = theta, sigma = Sigma)
  Sigmahat <- rWishart(1, n, Sigma/n)

  Vhat_0 <- Sigmahat[1,1,1]
  Vhat <- Sigmahat[-1,-1,1]
  Chat <- Sigmahat[-1,1,1]
  deltahat <- thetahat[-1] - thetahat[1]
  
  Phat <- Vhat_0 - Chat
  That <- Vhat_0 + Vhat - (matrix(1,nrow = k-1) %*% matrix(Chat, ncol = k-1)) - 
    (matrix(Chat,nrow = k-1) %*% matrix(1, ncol = k-1))
  Jhat <- mvnfast::rmvn(1000, mu = deltahat, sigma = That)
  Khat <- apply(Jhat, 1, function(j) {
    (t(Phat) %*% solve(That) %*% j %*% t(j) %*% solve(That) %*% j) /
      (1 + t(j) %*% solve(That) %*% j)
  })
  E_Khat <- mean(Khat)
  V_Khat <- var(Khat)
  E_Khat2 <- mean(Khat^2)
  rhohat <- E_Khat/(t(Phat) %*% solve(That) %*% deltahat)
  lambdahat <- E_Khat2/(t(Phat) %*% solve(That) %*% (That + deltahat %*% t(deltahat)) %*% solve(That) %*% Phat)
  
  msehat_G <- Vhat_0 + (lambdahat - 1) * t(Phat) %*% solve(That) %*% Phat + (t(Phat) %*% solve(That) %*% deltahat)^2 * (2*(1-rhohat) - 1 + lambdahat)
  
  out_ds <- 
    tibble(
      E_K,
      E_Khat,
      E_K2,
      E_Khat2,
      rho,
      rhohat,
      lambda,
      lambdahat,
      mse_G,
      msehat_G
    )
})
```

Below we'll show the true values and average estimated values for *E*(*K*),*E*(*K*<sup>2</sup>),*ρ*, *λ*, and *E*(*G*<sup>2</sup>).

``` r
sim_res <- sim_l %>% bind_rows
sim_res %>%
  summarise_all(mean)
```

    ## # A tibble: 1 x 10
    ##     E_K E_Khat  E_K2 E_Khat2   rho rhohat lambda lambdahat  mse_G msehat_G
    ##   <dbl>  <dbl> <dbl>   <dbl> <dbl>  <dbl>  <dbl>     <dbl>  <dbl>    <dbl>
    ## 1 0.373  0.389 0.213   0.294 0.885  0.915  0.828     0.848 0.0966   0.0931
