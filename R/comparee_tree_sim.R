library(dplyr)
library(clustermq)
library(synthate)
library(callr)

ate_list <- list(
  ipw2_ate,
  regr_ate,
  dr_ate,
  strat_ate)

tree_sim <- function(ate_list, n, j, d) {
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
  
  hte <- het_trt_grf(this_data, cov_ids = cov_ids)
  mod_data <- remove_effect_from_data(this_data, hte)
  
  thetahat <- estimate_ates(this_data,
                            ate_list,
                            cov_ids = cov_ids,
                            outcome_fm = stringr::str_c('d + ', outcome_fm),
                            outcome_fam = outcome_fam)
  
  tree_b <- tree_method_bhat(this_data, theta_0 = hte, ate_list = ate_list, cov_ids = cov_ids, outcome_fm = outcome_fm, outcome_fam = outcome_fam)
  tree_b
}

Q(tree_sim, 
  j = rep(1:4, each = 3),
  d = rep(c('ks', 'ld', 'ls'), 4),
  const=list(
    ate_list = ate_list,
    n = 500),
  n_jobs = 3
)
