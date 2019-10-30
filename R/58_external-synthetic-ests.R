devtools::install_github('denisagniel/synthate')
library(tidyverse)
library(here)
library(glue)
library(synthate)
library(clustermq)

sim_res <- read_rds(here('results/canonical_sim.rds'))
sim_res <- bind_rows(sim_res) %>%
  filter(d != 'ik') %>%
  rename(theta = thetahat,
         boot = demeaned_theta)

options(
  clustermq.defaults = list(ptn="short",
                            log_file="Rout/log%a.log",
                            time_amt = "1:00:00"
  )
)

thisfn <- function(theta, boot, estimators = NULL, ...) {
  library(tidyverse)
  library(here)
  library(glue)
  library(synthate)
  
  synthetic_subset(theta = theta, 
                   boot = boot, 
                   estimators = estimators, 
                   ate_0 = 0,
                   bias_type = 'bootstrap',
                   name_0 = 'ate_regr', ...)
}

sim_out <- sim_res %>%
  mutate(synth_ests = Q_rows(sim_res, thisfn,n_jobs = 100))
sim_out <- sim_out %>%
  select(-boot, -demeaned_theta) %>%
  unnest(synth_ests)
write_rds(sim_out, here('results/synthetic-ests_external.rds'))
