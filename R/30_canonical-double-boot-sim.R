
remotes::install_github('denisagniel/synthate')  
tmpdir <- '/n/data1/hms/dbmi/zaklab/dma12/synthetic-causal-estimation/tmp-boot/'
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
  j = 1:2,
  n = c(500),
  dgp = c('ks', 'ld'),
  run = 1:1000
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
#' Specify simulation functions.
#'
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
  # browser()
  set.seed(s)
  #'
  #' Generate the data.
  #' 
  gen_mod <- generate_data(n = n, dgp = d, 
                           correct_outcome = (j %in% c(1,3)),
                           correct_ps = (j %in% 1:2))
  
  inside_fn <- function(gen_mod, boot = FALSE, ate_list, B) {
    this_data <- gen_mod$data
    if (boot) {
      this_data <- this_data %>%
        sample_frac
    }
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
    predict_delta <- function(d) {
      d$y
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
    
    thetahat_s <- synthetic_subset(thetahat, boot = boot_theta)
    thetahat_s
  }
  
  initial_theta_s <- inside_fn(gen_mod, boot = FALSE,
                               ate_list, B)
  boot_theta_l <- map(1:B, function(b) {
    inside_fn(gen_mod, boot = TRUE, ate_list, B)
  })
  
  boot_res <- bind_rows(boot_theta_l) %>%
    group_by(theta_0) %>%
    summarise(
      boot_var = var(ate),
      boot_se = sd(ate),
      boot_q_l = quantile(ate, 0.025),
      boot_q_h = quantile(ate, 0.975)
    )
  out_df <- initial_theta_s %>%
    inner_join(boot_res)
  saveRDS(out_df, 
          glue(tmpdir,'tmp-res_n-{n}_d-{d}_j-{j}_s-{s}_B-{B}.rds'))
  out_df
}  

options(
  clustermq.defaults = list(ptn="medium",
                            log_file="Rout/log%a.log",
                            time_amt = "120:00:00"
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
             n_jobs = 250
)
saveRDS(sim_res, 
        here(glue('results/canonical-double-boot-sim.rds'))
)
fs::dir_delete(tmpdir)

sessionInfo()
