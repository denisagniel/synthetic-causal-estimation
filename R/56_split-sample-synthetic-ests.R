devtools::install_github('denisagniel/synthate')
library(tidyverse)
library(here)
library(glue)
library(synthate)
library(clustermq)

main_res <- read_rds(here('results/canonical-sim-results.rds'))
sim_res <- read_rds(here('results/canonical-split-sample_sim.rds'))
sim_res <- keep(sim_res, ~ all(class(.) != 'error'))
sim_res <- bind_rows(sim_res) %>%
  filter(d != 'ik') %>%
  inner_join(main_res) %>%
  rename(thetahat_a = a_thetahat,
         thetahat_b = b_thetahat,
         boot = boot_theta)
  
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
  
  synthate::synthetic_split_subset(a_thetahat, b_thetahat, boot, estimators, ...)
}

sim_out <- sim_res %>%
  mutate(split_sample_ests = Q_rows(sim_res, thisfn,n_jobs = 100))
sim_out <- sim_out %>%
  select(-boot, -demeaned_theta) %>%
  unnest(split_sample_ests)
write_rds(sim_out, here('results/synthetic-ests_split-sample.rds'))
