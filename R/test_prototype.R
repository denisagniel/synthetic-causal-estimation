
# devtools::install_github('denisagniel/synthate')
library(dplyr)
library(clustermq)
library(ggplot2)
library(here)
library(synthate)
library(purrr)
library(readr)
library(glue)

tree_sim <- function(ate_list, n, j, d, B, s) {
  library(splines)
  library(stringr)
  library(purrr)
  library(tidyr)
  library(dplyr)
  library(clustermq)
  library(synthate)
  library(grf)
  
  print(
    glue::glue('Sample size is {n}; the outcome is {(j %in% c(1,3))}; the PS is {(j %in% c(1,2))}; the DGP is {d}; the seed is {s}.')
  )
  set.seed(s)
  # browser()
  gen_mod <- generate_data(n = n, dgp = d, 
                           correct_outcome = (j %in% c(1,3)),
                           correct_ps = (j %in% 1:2))
  this_data <- gen_mod$data
  outcome_fm <- gen_mod$outcome_fm
  outcome_fam <- gen_mod$outcome_fam
  ps_fm <- gen_mod$ps_fm
  ps_fam <- gen_mod$ps_fam
  cov_ids <- gen_mod$cov_ids
  print('data generated..')

  this_data <- estimate_scores(this_data, outcome_fm = outcome_fm,
                               ps_fm = ps_fm,
                               ps_fam = ps_fam,
                               outcome_fam = outcome_fam)
  print('scores estimated...')
  thetahat <- estimate_ates(this_data,
                            ate_list,
                            cov_ids = cov_ids,
                            outcome_fm = stringr::str_c('d + ', outcome_fm),
                            outcome_fam = outcome_fam)
  print('initial thetas estimated...')
  X <- this_data %>% dplyr::select(one_of(cov_ids))
  W <- this_data %>% pull(d)
  Y <- this_data$y
  
  grf_fit <- grf::causal_forest(X = X, Y = Y, W = W)
  
  # browser()
  print('prediction model fit...')
  # browser()
  predict_delta <- function(d) {
    as.vector(predict(grf_fit, newdata = d)$predictions)
  }

  
  resample_thetas <- resample_fn(dat = this_data,
                                 dpredfn = predict_delta,
                                 B = B,
                                 ate_list = ate_list,
                                 outcome_fm = outcome_fm,
                                 ps_fm = ps_fm,
                                 ps_fam = ps_fam,
                                 outcome_fam = outcome_fam,
                                 cov_ids = cov_ids)
  print('resampling done...')
  boot_theta <- resample_thetas[[1]] 
  null_theta <- resample_thetas[[2]] 

  out_df <- tibble(
    n = n,
    d = d,
    j = j,
    run = s,
    thetahat = list(thetahat),
    boot_theta = list(boot_theta),
    demeaned_theta = list(null_theta)
  )
  out_df
}

# sim_parameters <- expand.grid(
#   run = 1:500,
#   j = 1:4,
#   n = c(500, 2000),
#   d = c('ls')
# )
sim_parameters <- expand.grid(
  run = 2,
  j = 1,
  n = c(500),
  d = c('pa', 'ld', 'ks', 'fi', 'ik', 'iw', 'ls')
)

# 
# tree_sim(j = 2,
#                   n = 500,
#                   s = 1,
#                   ate_list =  list(
#                     ipw1 = ipw1_ate,
#                     ipw2 = ipw2_ate,
#                     ipw3 = ipw3_ate,
#                     strat = strat_ate,
#                     strat_regr = strat_regr_ate,
#                     match_ps = match_ps_ate,
#                     match_prog = match_prog_ate,
#                     match_both = match_both_ate,
#                     cal_ps = caliper_ps_ate,
#                     cal_both = caliper_both_ate,
#                     # grf = grf_ate,
#                     regr = regr_ate,
#                     dr = dr_ate,
#                     bal = bal_ate,
#                     hdbal = highdim_bal_ate
#                   ),
#                   B = 200,
#                   d = 'iw')
# for (dd in unique(sim_parameters$d)) {
#   this_sim <- sim_parameters %>%
#     filter(d == dd) 
#   this_sim <- this_sim %>%
#     mutate(sim = as.character(1:nrow(this_sim)))
this_sim <- sim_parameters
  
  options(
    clustermq.defaults = list(ptn="short",
                              log_file="Rout/log%a.log",
                              time_amt = "12:00:00"
    )
  )
  sim_res <- Q(tree_sim, 
               j = this_sim$j,
               n = this_sim$n,
               s = this_sim$run,
               d = this_sim$d,
               const = list(
                 ate_list = list(
                   ipw1 = ipw1_ate,
                   ipw2 = ipw2_ate,
                   ipw3 = ipw3_ate,
                   strat = strat_ate,
                   strat_regr = strat_regr_ate,
                   match_ps = match_ps_ate,
                   match_prog = match_prog_ate,
                   match_both = match_both_ate,
                   cal_ps = caliper_ps_ate,
                   cal_both = caliper_both_ate,
                   # grf = grf_ate,
                   regr = regr_ate,
                   dr = dr_ate,
                   bal = bal_ate,
                   hdbal = highdim_bal_ate
                 ),
                 B = 20),
               n_jobs = 5
  ) %>% bind_rows
  saveRDS(sim_res, 
          here(glue('results/test_all_sim_results.rds'))
  )




sessionInfo()
