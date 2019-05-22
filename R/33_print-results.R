#' ---
#' title: "Looking at asymptotic variance results"
#' output: github_document
#' ---
#' 
library(knitr)
opts_chunk$set(warning = FALSE, message = FALSE, cache = FALSE, fig.width = 7, fig.height = 7)

#'

library(tidyverse)
library(here)
library(knitr)
library(formattable)

avar_res <- read_csv(here('results/prelim_asymptotic-var-results.csv'))

## Standard error accuracy
avar_res %>%
  select(theta_0, d, j, true_se, asymp_se, boot_se, asymp_se_ratio, boot_se_ratio) %>%
  arrange(d, j, theta_0) %>% kable(digits = 3)

## Confidence interval coverage
avar_res %>%
  select(theta_0, d, j, bias, asymp_se_ratio, boot_se_ratio, asymp_ci_coverage, boot_nci_coverage, boot_qci_coverage) %>%
  arrange(d, j, theta_0) %>% kable(digits = 3)

