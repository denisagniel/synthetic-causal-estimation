#' ---
#' title: "Canonical simulation"
#' output: github_document
#' ---
#' 
library(knitr)
opts_chunk$set(warning = FALSE, message = FALSE, cache = FALSE, fig.width = 7, fig.height = 7)

#'
remotes::install_github('denisagniel/synthate')  
tmpdir <- '/n/data1/hms/dbmi/zaklab/dma12/synthetic-causal-estimation/tmp/'
fs::dir_create(tmpdir)

library(splines)
  library(stringr)
  library(purrr)
  library(tidyr)
  library(dplyr)
  library(clustermq)
  library(synthate)
  library(grf)
library(glue)
#'
#' Set up simulations settings.
#' 
sim_params <- expand.grid(
  dgp = c('ks', 'ld', 'ls', 'ik', 'fi', 'iw', 'pa'),
  j = 1:4,
  n = c(500, 2000, 5000),
  run = 1:3
)
#'  
#' Proposed ATE list. 
#' 
  ate_list <- list(
    ipw = ipw2_ate,
    regr = regr_ate,
    strat_regr = strat_regr_ate,
    dr = dr_ate,
    strat = strat_ate,
    
    match_ps = match_ps_ate,
    match_prog = match_prog_ate,
    match_both = match_both_ate,
    cal_ps = caliper_ps_ate,
    cal_prog = caliper_prog_ate,
    cal_both = caliper_both_ate,
    
    bal = bal_ate,
    hdbal = highdim_bal_ate
  )
  
    
  #'
  #' Specify simulation function.
  #' 
sim_fn <- function(n, j, d, s, ate_list, B, tmpdir) {
  library(splines)
  library(stringr)
  library(purrr)
  library(tidyr)
  library(dplyr)
  library(clustermq)
  library(synthate)
  library(grf)
  library(glue)
  select <- dplyr::select
  print(
    glue::glue('Sample size is {n}; the outcome is {(j %in% c(1,3))}; the PS is {(j %in% c(1,2))}; the DGP is {d}; the seed is {s}.')
  )
  set.seed(s)
  #'
  #' Generate the data.
  #' 
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
  #'
  #' Do the estimation.
  #' 
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
  #'
  
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
  saveRDS(out_df, 
          glue(tmpdir,'tmp-res_n-{n}_d-{d}_j-{j}_s-{s}.rds'))
}  

sim_res <- Q(sim_fn, 
             j = sim_params$j,
             n = sim_params$n,
             d = sim_params$d,
             s = sim_params$run,
             const = list(
               ate_list = ate_list,
               B = 200,
               tmpdir = tmpdir),
             fail_on_error = FALSE,
             n_jobs = 30
)
saveRDS(sim_res, 
        here(glue('results/canonical_sim.rds'))
)
fs::dir_delete(tmpdir)
sim_tib <- bind_rows(sim_res)
saveRDS(sim_tib, 
        here(glue('results/canonical_sim.csv'))
)
sessionInfo()
