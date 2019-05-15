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

avar_res <- read_csv(here('results/prelim_asymptotic-var-results.csv'))
avar_res %>% kable(digits = 3)

