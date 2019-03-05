#' ---
#' title: "Simulation to "
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
  library(zeallot)
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
  
  c(thetahat, bhat, Chat) %<-% fit_fn(this_data, 
                                      gen_mod = gen_mod, 
                                      ate_list = ate_list,
                                      C = NULL,
                                      B = B)
  X <- this_data %>% select(one_of(cov_ids))
  W <- this_data %>% pull(d)
  Y <- this_data$y
  grf_fit <- grf::causal_forest(X = X, Y = Y, W = W)
  grf_ate <- grf::average_treatment_effect(grf_fit)[1]
  
  c(split_theta, split_bhat) %<-% split_sample_fn(this_data, 
                                                  gen_mod = gen_mod, 
                                                  ate_list = ate_list,
                                                  C = Chat,
                                                  B = B)
  
  multiple_splits <- map(1:10, function(i) {
    split_sample_fn(this_data, 
                    gen_mod = gen_mod, 
                    ate_list = ate_list,
                    C = Chat,
                    B = B)
  })
  
  all_split_thetas <- map(multiple_splits, 'ss_thetas') %>%
    bind_rows(.id = 'split')
  all_split_bs <- map(multiple_splits, 'ss_bs') %>%
    bind_rows(.id = 'split')
  # browser()
  
  ten_split_theta <- all_split_thetas %>%
    group_by(type) %>%
    summarise(theta_s = mean(theta_s)) %>%
    ungroup
  ten_split_b <- all_split_bs %>%
    group_by(type, est) %>%
    summarise(b = mean(b)) %>%
    ungroup
  
  all_thetas <- list(
    thetahat %>%
      transmute(
        type = case_when(
          type == 'raw' ~ theta_0,
          TRUE ~ type
          ),
        ate,
        synthetic,
        true_ate,
        splits = 0),
    tibble(
      type = 'grf',
      ate = grf_ate,
      synthetic = FALSE,
      true_ate = gen_mod$true_ate,
      splits = 0
    ),
    split_theta %>%
      transmute(type,
                ate = theta_s,
                synthetic = TRUE,
                true_ate = gen_mod$true_ate,
                splits = 1),
    ten_split_theta %>%
      transmute(type,
                ate = theta_s,
                synthetic = TRUE,
                true_ate = gen_mod$true_ate,
                splits = 10)
  ) %>% bind_rows()
  
  all_bs <- list(
    bhat %>%
      transmute(
        type,
        est,
        b,
        splits = 0),
    split_bhat %>%
      transmute(type,
                est,
                b,
                splits = 1),
    ten_split_b %>%
      transmute(type,
                est,
                b,
                splits = 10)
  ) %>% bind_rows()
  list(all_thetas = all_thetas,
       all_bs = all_bs)
}

sim_parameters <- expand.grid(
  run = 1:500,
  j = 1:4,
  n = c(500, 2000),
  d = c('ls', 'iw')
)
# 
tree_sim(j = 2,
                  n = 500,
                  s = 1,
                  ate_list = list(
                    ipw2_ate,
                    regr_ate,
                    dr_ate,
                    strat_ate),
                  B = 20,
                  d = 'ls')
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
    inner_join(this_sim)
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
    inner_join(this_sim)
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
