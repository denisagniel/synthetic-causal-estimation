library(tidyverse)
library(here)
library(glue)
library(synthate)
library(patchwork)
library(clustermq)

sim_res <- read_rds(here('results/canonical-sim-results.rds')) %>%
  filter(d != 'ik') %>%
  rename(theta = thetahat,
         boot = boot_theta)
  
options(
  clustermq.defaults = list(ptn="short",
                            log_file="Rout/log%a.log",
                            time_amt = "1:00:00"
  )
)

sim_out <- sim_res %>%
  mutate(synth_ests = Q_rows(tst, synthetic_subset,n_jobs = 100))
sim_out <- sim_out %>%
  select(-boot, -demeaned_theta) %>%
  unnest(synth_ests)
write_rds(sim_out, here('results/synthetic-ests.rds'))
