tmpdir <- '/n/data1/hms/dbmi/zaklab/dma12/synthetic-causal-estimation/tmp-boot/'

library(dplyr)
library(here)
library(purrr)
library(glue)

sim_params <- expand.grid(
  j = 1:2,
  n = c(500),
  dgp = c('ks', 'ld'),
  run = 1:1000
)
sim_res <- map(1:nrow(sim_params), function(i) {
  # browser()
  sp <- sim_params[i,]
  n <- sp$n
  j <- sp$j
  d <- sp$dgp
  s <- sp$run
  B <- 200
  
  this_sim <- try(readRDS(glue(tmpdir,'tmp-res_n-{n}_d-{d}_j-{j}_s-{s}_B-{B}.rds')
  ))
  if (class(this_sim) == 'try-error') {
    return(NULL)
  } else return(this_sim %>%
                  mutate(n = n,
                         j = j,
                         d = d,
                         run = s))
})

full_res <- bind_rows(sim_res) %>%
  mutate(true_ate = if_else(d == 'ks', 40, 2))

res_sum <- full_res %>%
  group_by(theta_0, n, j, d) %>%
  summarise(true_var = var(ate),
            est_var = mean(var),
            true_se = sd(ate),
            est_se = mean(sqrt(var)),
            bias = mean(ate - true_ate),
            ci_coverage = mean(ate - 1.96*sqrt(var) < true_ate &
                                 ate + 1.96*sqrt(var) > true_ate),
            nsim = n()) %>%
  ungroup %>%
  mutate(se_ratio = est_se/true_se)
readr::write_csv(res_sum, here('results/prelim_asymptotic-var-results.csv'))
