Compute MSEs of canonical simulations
================
dagniel
2019-04-24

``` r
library(knitr)
opts_chunk$set(warning = FALSE, message = FALSE, cache = FALSE, fig.width = 7, fig.height = 7)
```

``` r
library(tidyverse)
library(here)
library(glue)
library(synthate)
```

Pull in the results.

``` r
full_res <- readRDS(here(
  'results/canonical-sim-results.rds'
))
```

Create synthetic estimators.

``` r
synth_res <- full_res %>%
  mutate(thetahat_s = purrr::map2(
    thetahat,
    boot_theta,
    synthetic_subset
  ))
```

Make dataset that just includes synthetic estimators.

``` r
theta_s_ds <- synth_res %>%
  select(n, d, j, run,true_ate, thetahat_s) %>%
  unnest(thetahat_s)
```

Compute MSEs.

``` r
theta_s_mse <- theta_s_ds %>%
  group_by(n, d, j, true_ate, theta_0) %>%
  summarise(synthetic_mse = mean((ate - true_ate)^2),
            synthetic_bias = mean(ate - true_ate),
            synthetic_var = var(ate)) %>%
  ungroup
write_csv(theta_s_mse,
          here('results/canonical-sim_synthetic-mses.csv'))
```

Do the same for the candidate estimators.

``` r
theta_ds <- synth_res %>%
  select(n, d, j, run, true_ate, thetahat) %>%
  unnest(thetahat) %>%
  gather(theta_0, ate, -(n:true_ate))

theta_mse <- theta_ds %>%
  group_by(n, d, j, true_ate, theta_0) %>%
  summarise(candidate_mse = mean((ate - true_ate)^2, na.rm = TRUE),
            candidate_bias = mean(ate - true_ate, na.rm = TRUE),
            candidate_var = var(ate, na.rm = TRUE)) %>%
  ungroup
write_csv(theta_mse,
          here('results/canonical-sim_candidate-mses.csv'))
```
