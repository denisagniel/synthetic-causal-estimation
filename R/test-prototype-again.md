Operating on the prototype
================
dagniel
Tue Mar 12 17:17:09 2019

``` r
library(knitr)
opts_chunk$set(warning = FALSE, message = FALSE, cache = FALSE, fig.width = 7, fig.height = 7)
```

``` r
library(tidyverse)
library(here)
library(glue)
library(synthate)

sim_res <- readRDS(here('results/test_all_sim_results.rds'))
file_size <- fs::fs_bytes(file.size(here('results/test_all_sim_results.rds')))
```

I have run a short simulation using the prototype, one simulation for each of the 7 DGPs. This file file is 3.014410^{4} bytes, so if we extrapolate out to 1000 simulations, four settings, three sample sizes, then we would have a file of 3.6172810^{8}. That's not that bad!

The current version does not incorporate multiple external predictive models for demeaning, so if we want to do additional of those, then we would again double or triple the file size and time.

Here's another demonstration of how to operate on these results.

``` r
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
```

    ##     n  d j run dr_based_theta_s bal_based_theta_s
    ## 1 500 pa 1   2        0.9318383         1.5387283
    ## 2 500 ld 1   2        2.1437474         1.9866926
    ## 3 500 ks 1   2       39.9283348        39.6099777
    ## 4 500 fi 1   2        0.2517489         0.7929425
    ## 5 500 ik 1   2     1014.3798996     -8435.5199203
    ## 6 500 iw 1   2        2.0171716         2.1903079
    ## 7 500 ls 1   2       -0.4125659        -0.2985015
    ##   demeaned_matching_theta_s
    ## 1                 1.5369530
    ## 2                 2.0975252
    ## 3                39.5026051
    ## 4                -3.8250852
    ## 5             -8460.2483103
    ## 6                 2.0829436
    ## 7                -0.3559165

``` r
sessionInfo()
```

    ## R version 3.5.2 (2018-12-20)
    ## Platform: x86_64-apple-darwin15.6.0 (64-bit)
    ## Running under: OS X El Capitan 10.11.6
    ## 
    ## Matrix products: default
    ## BLAS: /Library/Frameworks/R.framework/Versions/3.5/Resources/lib/libRblas.0.dylib
    ## LAPACK: /Library/Frameworks/R.framework/Versions/3.5/Resources/lib/libRlapack.dylib
    ## 
    ## locale:
    ## [1] en_US.UTF-8/en_US.UTF-8/en_US.UTF-8/C/en_US.UTF-8/en_US.UTF-8
    ## 
    ## attached base packages:
    ## [1] stats     graphics  grDevices utils     datasets  methods   base     
    ## 
    ## other attached packages:
    ##  [1] synthate_0.1.0  glue_1.3.0      here_0.1        forcats_0.3.0  
    ##  [5] stringr_1.4.0   dplyr_0.8.0.1   purrr_0.3.0     readr_1.3.1    
    ##  [9] tidyr_0.8.2     tibble_2.0.1    ggplot2_3.1.0   tidyverse_1.2.1
    ## [13] knitr_1.21     
    ## 
    ## loaded via a namespace (and not attached):
    ##  [1] tidyselect_0.2.5 xfun_0.4         haven_2.0.0      lattice_0.20-38 
    ##  [5] colorspace_1.4-0 generics_0.0.2   htmltools_0.3.6  yaml_2.2.0      
    ##  [9] rlang_0.3.1      pillar_1.3.1     withr_2.1.2      modelr_0.1.2    
    ## [13] readxl_1.2.0     plyr_1.8.4       munsell_0.5.0    gtable_0.2.0    
    ## [17] cellranger_1.1.0 rvest_0.3.2      evaluate_0.12    highr_0.7       
    ## [21] broom_0.5.1      Rcpp_1.0.0       scales_1.0.0     backports_1.1.3 
    ## [25] jsonlite_1.6     fs_1.2.6         hms_0.4.2        digest_0.6.18   
    ## [29] stringi_1.3.1    grid_3.5.2       rprojroot_1.3-2  quadprog_1.5-5  
    ## [33] cli_1.0.1        tools_3.5.2      magrittr_1.5     lazyeval_0.2.1  
    ## [37] crayon_1.3.4     pkgconfig_2.0.2  Matrix_1.2-15    xml2_1.2.0      
    ## [41] matrixcalc_1.0-3 lubridate_1.7.4  assertthat_0.2.0 rmarkdown_1.11  
    ## [45] httr_1.4.0       rstudioapi_0.9.0 R6_2.4.0         nlme_3.1-137    
    ## [49] compiler_3.5.2
