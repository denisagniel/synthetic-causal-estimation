Finding unbiased estimators
================
dagniel
2019-12-12

``` r
library(knitr)
opts_chunk$set(warning = FALSE, message = FALSE, cache = FALSE, fig.width = 7, fig.height = 7)
```

``` r
library(tidyverse)
library(here)
library(glue)
library(tidyr)
library(synthate)
sim_res <- read_rds(here('results/canonical-sim-results.rds'))
base_res <- sim_res %>%
  select(-boot_theta, -demeaned_theta) %>%
  unnest(thetahat) %>%
  filter(d != 'ik')
ss_res <- read_rds(here('results/canonical-split-sample_sim.rds'))
ss_res <- keep(ss_res, ~ all(class(.) != 'error'))
full_res <- bind_rows(ss_res) %>%
  filter(d != 'ik') %>%
  inner_join(sim_res %>% select(-thetahat)) %>%
  mutate(thetahat_a = a_thetahat,
         thetahat_b = b_thetahat,
         boot = boot_theta)

base_sum <- base_res %>%
  gather(theta, thetahat, ate_ipw_2:ate_bhd) %>%
  group_by(n, d, j, true_ate, theta) %>%
  summarise(bias_0 = mean(thetahat - true_ate, na.rm = TRUE),
            var_0 = var(thetahat, na.rm = TRUE),
            mse_0 = mean((thetahat - true_ate)^2, na.rm = TRUE))

unbiased_ests <- base_sum %>%
  filter(abs(bias_0) < 0.001*true_ate) %>%
  group_by(n, d, j) %>%
  mutate(n_ests = n()) %>%
  filter(n_ests >= 2) %>%
  ungroup 

sims_to_run <- unbiased_ests %>%
  select(n,d,j, theta) %>%
  nest(estimators = c(theta))
write_rds(sims_to_run, 
          here('results/list-of-unbiased-estimators-in-dgps.rds'))
```
