
df <- read_csv(here("data/clean/pov_demos_combined.csv"))



library(tidyverse)
library(haven)
library(Synth)
library(devtools)
library(SCtools)

read_data <- function(df)
{
  full_path <- paste("https://raw.github.com/scunning1975/mixtape/master/", 
                     df, sep = "")
  df <- read_dta(full_path)
  return(df)
}

texas <- read_data("texas.dta") %>%
  as.data.frame(.)

df <- as.data.frame(df)
df$pov_tot <- readr::parse_number(df$pov_tot)

df_out <- dataprep(
  foo = df,
  predictors = c("b_h_f_18to64", "b_n_f_18to64"),
  predictors.op = "mean",
  time.predictors.prior = 2010:2014, 
#  special.predictors = list(
#    list("bmprison", c(1988, 1990:1992), "mean"),
#    list("alcohol", 1990, "mean"),
#    list("aidscapita", 1990:1991, "mean"),
#    list("black", 1990:1992, "mean"),
#    list("perc1519", 1990, "mean")),
  dependent = "pov_tot",
  unit.variable = "fips",
  unit.names.variable = "state",
  time.variable = "year",
  treatment.identifier = 37,
  controls.identifier = c(1,2,4:6,8:13,15:36,38:42, 44:47,49:51,53:56),
  time.optimize.ssr = 2010:2014,
  time.plot = 2010:2019
)



synth_out <- synth(data.prep.obj = df_out)

path.plot(synth_out, df_out)

gaps.plot(synth_out, df_out)

placebos <- generate.placebos(df_out, synth_out, Sigf.ipop = 3)

plot_placebos(placebos)

mspe.plot(placebos, discard.extreme = TRUE, mspe.limit = 1, plot.hist = TRUE)
