Add true ATE to simulation results
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

full_res <- readRDS(here(
  'results/canonical_sim.rds'
))

ld <- data.frame(d = 'ld', j = 1:4, true_ate = 2)
ks <- data.frame(d = 'ks', j = 1:4, true_ate = 40)
iw <- data.frame(d = 'iw', j = 1:4, true_ate = 2)
pa <- data.frame(d = 'pa', j = 1:4, true_ate = 1)
fi <- data.frame(d = 'fi', j = 1:4, true_ate = c(3*27.4, 27.4*11, 3*27.4, 27.4*11))
ik <- data.frame(d = 'ik', j = 1:4, true_ate = 1000)
ls <- data.frame(d = 'ls', j = 1:4, true_ate = -0.4)

ate_ds <- ls %>%
  full_join(ks) %>%
  full_join(iw) %>%
  full_join(pa) %>%
  full_join(fi) %>%
  full_join(ik) %>%
  full_join(ls) %>%
  full_join(ld)
sim_res <- bind_rows(full_res) %>%
  inner_join(ate_ds)
saveRDS(sim_res, here('results/canonical-sim-results.rds'))
```
