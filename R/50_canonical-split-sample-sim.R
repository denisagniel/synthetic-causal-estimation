#' ---
#' title: "Canonical split-sample simulation"
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
library(here)
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
  library(here)
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
  thetahat <- estimate_ates(this_data,
                              ate_list,
                              cov_ids = cov_ids,
                              outcome_fm = stringr::str_c('d + ', outcome_fm),
                              outcome_fam = outcome_fam)
  print('scores estimated...')
  a_data <- this_data %>%
    sample_frac(0.5)
  b_data <- this_data %>%
    anti_join(a_data)
  a_data <- estimate_scores(a_data, outcome_fm = outcome_fm,
                  ps_fm = ps_fm,
                  ps_fam = ps_fam,
                  outcome_fam = outcome_fam)
  b_data <- estimate_scores(b_data, outcome_fm = outcome_fm,
                            ps_fm = ps_fm,
                            ps_fam = ps_fam,
                            outcome_fam = outcome_fam)
  a_thetahat <- estimate_ates(a_data,
                            ate_list,
                            cov_ids = cov_ids,
                            outcome_fm = stringr::str_c('d + ', outcome_fm),
                            outcome_fam = outcome_fam)
  b_thetahat <- estimate_ates(b_data,
                              ate_list,
                              cov_ids = cov_ids,
                              outcome_fm = stringr::str_c('d + ', outcome_fm),
                              outcome_fam = outcome_fam)
 
  
  out_df <- tibble(
    n = n,
    d = d,
    j = j,
    run = s,
    thetahat = list(thetahat),
    a_thetahat = list(a_thetahat),
    b_thetahat = list(b_thetahat)
  )
  out_df
  saveRDS(out_df, 
          glue(tmpdir,'tmp-split-sample-res_n-{n}_d-{d}_j-{j}_s-{s}.rds'))
}  

options(
  clustermq.defaults = list(ptn="short",
                            log_file="Rout/log%a.log",
                            time_amt = "1:00:00"
  )
)

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
             n_jobs = 10
)
saveRDS(sim_res, 
        here(glue('results/canonical-split-sample_sim.rds'))
)
fs::dir_delete(tmpdir)

sessionInfo()
