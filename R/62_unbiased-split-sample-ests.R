devtools::install_github('denisagniel/synthate')
library(tidyverse)
library(here)
library(glue)
library(synthate)
library(clustermq)

unbiased_ones <- read_rds(here('results/list-of-unbiased-estimators-in-dgps.rds'))
main_res <- read_rds(here('results/canonical_sim.rds')) %>%
  bind_rows %>%
  filter(d != 'ik') %>%
  select(-thetahat, -demeaned_theta)
sim_res <- read_rds(here('results/canonical-split-sample_sim.rds'))
sim_res <- keep(sim_res, ~ all(class(.) != 'error'))
sim_res <- bind_rows(sim_res) %>%
  filter(d != 'ik') %>%
  inner_join(main_res) %>%
  rename(thetahat_a = a_thetahat,
         thetahat_b = b_thetahat,
         boot = boot_theta) %>%
  inner_join(unbiased_ones)
  
options(
  clustermq.defaults = list(ptn="short",
                            log_file="Rout/log%a.log",
                            time_amt = "4:00:00"
  )
)

thisfn <- function(thetahat_a,thetahat_b, boot, estimators = NULL, ...) {
  library(tidyverse)
  library(here)
  library(glue)
  library(synthate)
  
  synthetic_split_subset(thetahat_a = thetahat_a, 
                         thetahat_b = thetahat_b, 
                         boot = boot, 
                         estimators = estimators, ...)
}
prevfn <- function(thetahat, boot, estimators = NULL, ...) {
  library(tidyverse)
  library(here)
  library(glue)
  library(synthate)
  
  synthetic_subset(thetahat, boot, estimators, ...)
}
sim_out <- sim_res %>%
  mutate(split_sample_ests = Q_rows(sim_res, thisfn, n_jobs = 100)) %>%
  mutate(raw_diff_ests = Q_rows(sim_res, prevfn, n_jobs = 100))
sim_out <- sim_out %>%
  select(-boot) %>%
  unnest(split_sample_ests)
write_rds(sim_out, here('results/unbiased-synthetic-ests.rds'))
