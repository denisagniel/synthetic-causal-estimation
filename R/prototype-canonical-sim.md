Prototyping the canonical simulation code
================
dagniel
Wed Mar 13 07:55:29 2019

``` r
library(knitr)
opts_chunk$set(warning = FALSE, message = FALSE, cache = FALSE, fig.width = 7, fig.height = 7)
```

``` r
  library(splines)
  library(stringr)
  library(purrr)
  library(tidyr)
  library(dplyr)
  library(clustermq)
  library(synthate)
  library(grf)
```

Set some simulations settings for demonstration.

``` r
  n <- 2000
  j <- 2
  d <- 'ls'
  s <- 0
  B <- 200
```

Proposed ATE list.

``` r
  ate_list <- list(
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
    grf = grf_ate,
    regr = regr_ate,
    dr = dr_ate,
    bal = bal_ate,
    hdbal = highdim_bal_ate
  )
  
  
  print(
    glue::glue('Sample size is {n}; the outcome is {(j %in% c(1,3))}; the PS is {(j %in% c(1,2))}; the DGP is {d}; the seed is {s}.')
  )
```

    ## Sample size is 2000; the outcome is FALSE; the PS is TRUE; the DGP is ls; the seed is 0.

``` r
  set.seed(s)
```

Generate the data.
``` r
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
```

    ## [1] "data generated.."



Do the estimation.

``` r
  this_data <- estimate_scores(this_data, outcome_fm = outcome_fm,
                               ps_fm = ps_fm,
                               ps_fam = ps_fam,
                               outcome_fam = outcome_fam)
  print('scores estimated...')
```

    ## [1] "scores estimated..."

``` r
  thetahat <- estimate_ates(this_data,
                            ate_list,
                            cov_ids = cov_ids,
                            outcome_fm = stringr::str_c('d + ', outcome_fm),
                            outcome_fam = outcome_fam)
  print('initial thetas estimated...')
```

    ## [1] "initial thetas estimated..."

``` r
  X <- this_data %>% select(one_of(cov_ids))
  W <- this_data %>% pull(d)
  Y <- this_data$y
  
  grf_fit <- grf::causal_forest(X = X, Y = Y, W = W)
  # browser()
  print('prediction model fit...')
```

    ## [1] "prediction model fit..."

``` r
  # browser()
  predict_delta <- function(d) {
    as.vector(predict(grf_fit, newdata = d)$predictions)
  }
```
## How long do the estimators take to fit?
We can look at how long it takes to resample 200 of each estimator with $n = 2000$.

``` r
  map(ate_list, function(a) {
    tibble(time = system.time({
      resample_thetas <- 
        resample_fn(dat = this_data,
                    dpredfn = predict_delta,
                    B = B,
                    ate_list = list(a),
                    outcome_fm = outcome_fm,
                    ps_fm = ps_fm,
                    ps_fam = ps_fam,
                    outcome_fam = outcome_fam,
                    cov_ids = cov_ids)
    })[3])
  }) %>% bind_rows(.id = 'estimator') %>%
    kable
```

| estimator   |      time|
|:------------|---------:|
| ipw1        |   158.624|
| ipw2        |   157.419|
| ipw3        |   153.306|
| strat       |   152.628|
| strat\_regr |   172.123|
| match\_ps   |   197.943|
| match\_prog |   200.510|
| match\_both |   198.570|
| cal\_ps     |   197.973|
| cal\_both   |   183.712|
| grf         |  3044.819|
| regr        |   146.600|
| dr          |   147.272|
| bal         |   888.548|
| hdbal       |   684.644|

``` r
  resample_thetas <- resample_fn(dat = this_data,
                                 dpredfn = predict_delta,
                                 B = B,
                                 ate_list = ate_list,
                                 outcome_fm = outcome_fm,
                                 ps_fm = ps_fm,
                                 ps_fam = ps_fam,
                                 outcome_fam = outcome_fam,
                                 cov_ids = cov_ids)
```
It seems that the causal forest is much much slower than all others, and the balancing estimator is also quite slow. 

``` r  
  print('resampling done...')
```

    ## [1] "resampling done..."

``` r
  boot_theta <- resample_thetas[[1]] 
  null_theta <- resample_thetas[[2]] 
```

### Form of the object to save

You can save list columns in data frames, so we can save all of the estimators, all of the bootstrap estimates, and all of the demeaned bootstraps in their own separate columns. 
``` r
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
```

    ## # A tibble: 1 x 7
    ##       n d         j   run thetahat       boot_theta       demeaned_theta   
    ##   <dbl> <chr> <dbl> <dbl> <list>         <list>           <list>           
    ## 1  2000 ls        2     0 <data.frame [… <data.frame [20… <data.frame [200…



### Working with that object

Then I've written a couple of functions to operate on that data frame. The following function accepts a model object (which stores all of the formulas and variable names for the DGP) and a vector of estimator names. Then it spits out a new function that you can apply to the data frame with all the results to get the combined estimator just for those estimators. You can also pass it additional arguments to pass to the combination function, like which estimator to set as the $\theta_0$. 
``` r
  make_synthetic_fn <- function(gen_mod, ates = NULL, ...) {
    function(theta, boot) {
      if (!is.null(ates)) {
        theta_use <- theta %>% 
          select(one_of(ates))
        boot_use <- boot_theta %>% 
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
```
Then, we can use that function to, for example, create a new function to combine regression, IPW, DR, and balancing, setting DR as $\theta_0$.
``` r 
  my_synth_fn <- make_synthetic_fn(gen_mod, ates = c('ate_regr',
                                                     'ate_ipw_2',
                                                     'ate_dr',
                                                     'ate_bal'),
                                   name_0 = 'ate_dr'
                                   )
```
Then apply that function to the data frame like so:
``` r
  out_df %>%
    mutate(theta_s = unlist(map2(thetahat, boot_theta, my_synth_fn)))
```

    ## # A tibble: 1 x 8
    ##       n d         j   run thetahat    boot_theta    demeaned_theta  theta_s
    ##   <dbl> <chr> <dbl> <dbl> <list>      <list>        <list>            <dbl>
    ## 1  2000 ls        2     0 <data.fram… <data.frame … <data.frame [2…  -0.414
