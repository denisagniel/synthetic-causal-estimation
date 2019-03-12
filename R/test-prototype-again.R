#' ---
#' title: "Operating on the prototype"
#' output: github_document
#' ---
#' 
library(knitr)
opts_chunk$set(warning = FALSE, message = FALSE, cache = FALSE, fig.width = 7, fig.height = 7)

#'

library(tidyverse)
library(here)
library(glue)
library(synthate)

sim_res <- readRDS(here('results/test_all_sim_results.rds'))
file_size <- fs::fs_bytes(file.size(here('results/test_all_sim_results.rds')))
#' I have run a short simulation using the prototype, one simulation for each of the `r nrow(sim_res)` DGPs. This file file is `r file_size` bytes, so if we extrapolate out to 1000 simulations, four settings, three sample sizes, then we would have a file of `r file_size*1000*4*3`. That's not that bad! 
#' 
#' The current version does not incorporate multiple external predictive models for demeaning, so if we want to do additional of those, then we would again double or triple the file size and time.
#'
#' Here's another demonstration of how to operate on these results.

make_synthetic_fn <- function(gen_mod, ates = NULL, ...) {
  function(theta, boot) {
    if (!is.null(ates)) {
      theta_use <- theta %>% 
        select(one_of(ates))
      boot_use <- boot %>% 
        select(one_of(ates)) %>%
        as.matrix
    } else {
      theta_use <- theta
      boot_use <- boot
    }
    # browser()
    comb <- combine_estimators(ests = theta_use,
                               boot_ests = boot_use,
                               ...)
    comb$ate_res %>%
      filter(!shrunk) %>%
      pull(ate)
  }
}



basic_dr_fn <- make_synthetic_fn(gen_mod, ates = c('ate_regr',
                                                   'ate_ipw_2',
                                                   'ate_dr',
                                                   'ate_bal'),
                                 name_0 = 'ate_dr'
)
combine_all_match_fn <- make_synthetic_fn(gen_mod,
                                 name_0 = 'match_both')
just_matching_demeaned_fn <- make_synthetic_fn(gen_mod,
                                               ates = c(
                                                 'match_ps',
                                                 'match_prog',
                                                 'match_both',
                                                 'cal_match_ps',
                                                 'cal_match_both'
                                               ),
                                               bias_type = 'none',
                                               name_0 = 'match_ps')

sim_res %>%
  mutate(dr_based_theta_s = unlist(map2(thetahat, boot_theta, basic_dr_fn)),
         bal_based_theta_s = unlist(map2(thetahat, boot_theta, combine_all_match_fn)),
         demeaned_matching_theta_s = unlist(map2(thetahat, demeaned_theta, just_matching_demeaned_fn))) %>%
  select(-thetahat, -boot_theta, -demeaned_theta) %>%
  data.frame

sessionInfo()
