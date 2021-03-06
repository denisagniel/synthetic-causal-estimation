#' ---
#' title: "Simulation to compare various methods of computing synthetic ATEs"
#' output: github_document
#' ---
#' 
library(knitr)
opts_chunk$set(warning = FALSE, message = FALSE, cache = FALSE, fig.width = 7, fig.height = 7)

#'

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
  X <- this_data %>% select(one_of(cov_ids))
  W <- this_data %>% pull(d)
  Y <- this_data$y
  
  rf_fit <- randomForest::randomForest(as.formula(stringr::str_c('y ~ d + ', outcome_fm)), data = this_data)
  # browser()
  print('prediction model fit...')
  predict_delta <- function(d) {
    gen_mod$true_ate
  }
  predict_y <- function(d) {
    unlist(predict(rf_fit, newdata = d))
  }
  # browser()
  resample_thetas <- 
    resample_fn(dat = this_data,
                dpredfn = predict_delta,
                B = B,
                ate_list = ate_list,
                outcome_fm = outcome_fm,
                ps_fm = ps_fm,
                ps_fam = ps_fam,
                outcome_fam = outcome_fam)
  print('resampling done...')
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
    predict_delta(this_data)
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
  
  #----------------------------
  ## no bias
  #---------------------------
  no_bias_way <- combine_estimators(thetahat,
                                    boot_ests = boot_theta,
                                    name_0 = 'ate_dr',
                                    bias_type = 'none')
  #----------------------------
  ## shrunk bias
  #---------------------------
  shrunk_bias_way <- combine_estimators(thetahat,
                                    boot_ests = boot_theta,
                                    name_0 = 'ate_dr',
                                    bias_type = 'shrunk',
                                    n = n)
  
  alvvays <- list(
    old_way,
    boot_way,
    all_boot_way,
    null_way,
    gn_way,
    hybrid_boot_gn_way,
    no_bias_way,
    shrunk_bias_way
  )
  
  all_synthetic_thetas <- map(alvvays, 'ate_res') %>%
    bind_rows %>%
    filter(!shrunk) %>%
    mutate(type = c('old', 'boot', 'all_boot', 'null', 'gn', 'hybrid_gn', 'none', 'shrunk'),
           true_ate = gen_mod$true_ate)
  
  all_regular_thetas <- gather(thetahat, theta_0, ate) %>%
    mutate(synthetic = FALSE,
           var = NA,
           shrunk = FALSE,
           type = 'raw',
           true_ate = gen_mod$true_ate)
  
  all_thetas <- all_regular_thetas %>%
    full_join(all_synthetic_thetas)
  all_bs <- map(alvvays, 'b_res') %>%
    bind_rows %>%
    filter(!shrunk) %>%
    mutate(type = rep(c('old', 'boot', 'all_boot', 'null', 'gn', 'hybrid_gn', 'none', 'shrunk'), each = 4))
  
  return(list(thetas = all_thetas,
              bs = all_bs))
  
}

sim_parameters <- expand.grid(
  run = 1:500,
  j = 1:4,
  n = c(500, 2000, 8000),
  d = c('ls', 'iw')
)

# tree_sim(j = 2,
#                   n = 500,
#                   s = 1,
#                   ate_list = list(
#                     ipw2_ate,
#                     regr_ate,
#                     dr_ate,
#                     strat_ate),
#                   B = 20,
#                   d = 'ls')
for (dd in c('ls', 'iw')) {
      this_sim <- sim_parameters %>%
        filter(d == dd) 
      this_sim <- this_sim %>%
        mutate(sim = as.character(1:nrow(this_sim)))

      sim_res <- Q(tree_sim, 
                   j = this_sim$j,
                   n = this_sim$n,
                   s = this_sim$run,
                   const = list(
                     ate_list = list(
                       ipw2_ate,
                       regr_ate,
                       dr_ate,
                       strat_ate),
                     B = 200,
                     d = dd),
                   n_jobs = 100,
                   memory = 1000,
                   fail_on_error = FALSE
      )
      saveRDS(sim_res, 
              here(glue('results/comparison_sim_{dd}.rds'))
      )
      theta_res <- map(sim_res, 'thetas') %>%
        bind_rows(.id = 'sim') %>%
        inner_join(this_sim) %>%
        select(-(theta_0:shrunk))
      write_csv(theta_res,
                here(
                  glue('results/comparison_sim_thetas_{dd}.csv')
                ))
      mse_res <- theta_res %>%
        group_by(j, n, d, type) %>%
        summarise(mse = mean((ate - 2)^2))
      
      print(ggplot(mse_res, aes(x = type, y = mse)) +
        geom_col() +
        facet_wrap(n ~ j, scales = 'free'))
      
      b_res <- map(sim_res, 'bs') %>%
        bind_rows(.id = 'sim') %>%
        inner_join(this_sim) %>%
        select(-(theta_0:shrunk))
      write_csv(b_res, here(
        glue('results/comparison_sim_bs_{dd}.csv')
      ))
      
      b_sum <- b_res %>%
        group_by(j, n, d, est, type) %>%
        summarise(bhat = mean(b),
                  bvar = var(b))
      print(ggplot(b_sum, aes(x = est, y = bhat, group = type, fill = type)) +
        geom_col(position = 'dodge') +
        facet_wrap(n ~ j, scales = 'free'))
      
  }




sessionInfo()
