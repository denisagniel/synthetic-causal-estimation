library(here)
options(
  clustermq.defaults = list(ptn="short",
                            log_file="Rout/log%a.log",
                            time_amt = "12:00:00"
  )
)
rmarkdown::render(here(
  'R/20_canonical-sim.R'
))
