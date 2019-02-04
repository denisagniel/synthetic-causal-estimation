library(dplyr)
library(clustermq)
library(synthate)
library(callr)

tree_sim <- function(ate_list, n, j, d, B) {
  library(splines)
  library(cci)
  library(stringr)
  library(purrr)
  library(tidyr)
  library(dplyr)
  library(clustermq)
  
  gen_mod <- generate_data(n = n, dgp = d, 
                           correct_outcome = (j %in% c(1,3)),
                           correct_ps = (j %in% 1:2))
  this_data <- gen_mod$data
  outcome_fm <- gen_mod$outcome_fm
  outcome_fam <- gen_mod$outcome_fam
  ps_fm <- gen_mod$ps_fm
  ps_fam <- gen_mod$ps_fam
  cov_ids <- gen_mod$cov_ids
  this_data <- estimate_scores(this_data, outcome_fm = outcome_fm,
                               ps_fm = ps_fm,
                               ps_fam = ps_fam,
                               outcome_fam = outcome_fam)
  thetahat <- estimate_ates(this_data,
                            ate_list,
                            cov_ids = cov_ids,
                            outcome_fm = stringr::str_c('d + ', outcome_fm),
                            outcome_fam = outcome_fam)
  
  regr_intx <- lm(y ~ (z.1 + z.2 + z.3 + z.4)*d, data = this_data)
  predict_regr <- function(d) {
    predict(regr_intx, newdata = d)
  }
  
  resample_thetas <- 
    resample_fn(dat = this_data,
                predfn = predict_regr,
                B = B)
  boot_theta <- resample_thetas[[1]] %>% as.matrix
  null_theta <- resample_thetas[[2]] %>% as.matrix
  gn_theta <- resample_thetas[[3]] %>% as.matrix
  
  
  #------------------------
  ## this way uses regular bootstrap and raw differences
  #--------------------------
  old_way <- combine_estimators(thetahat,
                                boot_ests = boot_theta,
                                name_0 = 'ate_dr',
                                bias_type = 'raw_diff')
  #-------------------------
  ## naming a theta_0 but getting the biases comparing the 
  #### bootstrap estimates to the thetahat_0 from the original sample
  boot_way <- combine_estimators(thetahat,
                                 boot_ests = boot_theta,
                                 name_0 = 'ate_dr',
                                 bias_type = 'bootstrap')
  
  #-------------------------
  ## bing's new way, where you name a theta_0 and get the biases by computing the  
  #### bootstrap mean of thetahat_1 - thetahat_0
  all_boot_way <- combine_estimators(thetahat,
                                     boot_ests = boot_theta,
                                     name_0 = 'ate_dr',
                                     bias_type = 'bootstrap_all')
  #---------------------------
  ## null method
  null_way <- combine_estimators(thetahat,
                                 boot_ests = null_theta,
                                 name_0 = 'ate_dr',
                                 bias_type = 'bootstrap',
                                 ate_0 = 0)
  #--------------------------
  ## gn method
  gn_ate_0 <- mean(
    predict_regr(this_data %>% mutate(d = 1)) - 
      predict_regr(this_data %>% mutate(d = 0))
  )
  gn_way <- combine_estimators(thetahat,
                               boot_ests = gn_theta,
                               name_0 = 'ate_dr',
                               bias_type = 'bootstrap',
                               ate_0 = gn_ate_0)
  
  #--------------------------
  ## just using the prediction model for the ate, but not for the bootstrapping
  hybrid_boot_gn_way <- combine_estimators(thetahat,
                                           boot_ests = boot_theta,
                                           name_0 = 'ate_dr',
                                           bias_type = 'bootstrap',
                                           ate_0 = gn_ate_0)
  
  alvvays <- list(
    old_way,
    boot_way,
    all_boot_way,
    null_way,
    gn_way,
    hybrid_boot_gn_way
  )
  
  all_synthetic_thetas <- map(alvvays, 'ate_res') %>%
    bind_rows %>%
    filter(!shrunk) %>%
    mutate(type = c('old', 'boot', 'all_boot', 'null', 'gn', 'hybrid_gn'))
  
  all_bs <- map(alvvays, 'b_res') %>%
    bind_rows %>%
    filter(!shrunk) %>%
    mutate(type = rep(c('old', 'boot', 'all_boot', 'null', 'gn', 'hybrid_gn'), each = 4))
  
  return(thetas = all_synthetic_thetas,
         bs = all_bs)
  
}

Q(tree_sim, 
  j = rep(1:4, each = 3),
  d = rep(c('ks', 'ld', 'ls'), 4),
  const=list(
    ate_list = list(
      ipw2_ate,
      regr_ate,
      dr_ate,
      strat_ate),
    n = 500,
    B = 200),
  n_jobs = 3
)
