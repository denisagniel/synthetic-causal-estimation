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
            asymp_var = mean(var),
            boot_var = mean(boot_var),
            true_se = sd(ate),
            asymp_se = mean(sqrt(var)),
            boot_se = mean(sqrt(boot_var)),
            bias = mean(ate - true_ate),
            asymp_ci_coverage = mean(ate - 1.96*sqrt(var) < true_ate &
                                 ate + 1.96*sqrt(var) > true_ate),
            boot_nci_coverage = mean(ate - 1.96*sqrt(boot_var) < true_ate &
                                       ate + 1.96*sqrt(boot_var) > true_ate),
            boot_qci_coverage = mean(boot_q_l < true_ate &
                                       boot_q_h > true_ate),
            nsim = n()) %>%
  ungroup %>%
  mutate(asymp_se_ratio = asymp_se/true_se,
         boot_se_ratio = boot_se/true_se)
readr::write_csv(res_sum, here('results/prelim_asymptotic-var-results.csv'))
