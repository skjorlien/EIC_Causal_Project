##################################
# Author: Scott Kjorlien
# Date: 5/9/2022
# Description: 
#     Implementation of the tidysynth package for this project
#     Wrote the following helper functions:
#       generate_mean_predictors takes a list of variable names (as strings) 
#               and outputs a synth with those predictors built in
#       generate_lab_predictors takes a list of variables names with the structure "var_year"
#               the year is the lag reference. outputs a synth with those predictors built in
#       synth.out build the synthetic control model
#       generate_synth switches between models of interest, and allows for better user interface
#               includes option to output standard synth figures.
#########################################

rm(list=ls())

plot_placeboos <- function(data,time_window=NULL,prune_level=2){
  
  # Check if .meta is in data.
  if(!(".meta" %in% colnames(data))){stop("`.meta` column has been removed. `.meta` column needs to be included for `generte_control()` to work.")}
  
  # Grab meta data
  trt_time <- data$.meta[[1]]$treatment_time[1]
  time_index <- data$.meta[[1]]$time_index[1]
  treatment_unit <- data$.meta[[1]]$treatment_unit[1]
  unit_index <- data$.meta[[1]]$unit_index[1]
  outcome_name <- data$.meta[[1]]$outcome[1]
  
  # If no time window is specified for the plot, plot the entire series
  if(is.null(time_window)){ time_window <- unique(data$.original_data[[1]][[time_index]])}
  
  # Generate plot data
  plot_data <-
    data %>%
    grab_synthetic_control(placebo = TRUE) %>%
    dplyr::mutate(diff = real_y-synth_y) %>%
    dplyr::filter(time_unit %in% time_window) %>%
    dplyr::mutate(type_text = ifelse(.placebo==0,treatment_unit,"control units"),
                  type_text = factor(type_text,levels=c(treatment_unit,"control units")))
  
  
  # Pruning implementation-- if one of the donors falls outside two standard
  # deviations of the rest of the pool, it's dropped.
  caption <- ""
  if (prune_level>0){
    
    # Gather significance field
    sig_data = data %>% tidysynth::grab_signficance(time_window = time_window)
    
    # Treated units Pre-Period RMSPE
    thres <-
      sig_data %>%
      dplyr::filter(type=="Treated") %>%
      dplyr::pull(pre_mspe) %>%
      sqrt(.)
    
    # Only retain units that are 2 times the treated unit RMSPE.
    retain_ <-
      sig_data %>%
      dplyr::select(unit_name,pre_mspe) %>%
      dplyr::filter(sqrt(pre_mspe) <= thres*prune_level) %>%
      dplyr::pull(unit_name)
    
    plot_data <- plot_data %>% dplyr::filter(.id %in% retain_)
    caption <- "Pruned all placebo cases with a pre-period RMSPE exceeding two times the treated unit's pre-period RMSPE."
  }
  
  # Generate plot
  plot_data %>%
    ggplot2::ggplot(ggplot2::aes(time_unit,diff,group=.id,
                                 color=type_text,
                                 alpha=type_text,
                                 size=type_text)) +
    ggplot2::geom_hline(yintercept = 0,color="black",linetype=2) +
    ggplot2::geom_vline(xintercept = trt_time,color="black",linetype=3) +
    ggplot2::geom_line() +
    ggplot2::scale_color_manual(values=c("#b41e7c","grey60")) +
    ggplot2::scale_alpha_manual(values=c(1,.4)) +
    ggplot2::scale_size_manual(values=c(1,.5)) +
    ggplot2::labs(color="",alpha="",size="",y=outcome_name,x=time_index,
                  title=paste0("Difference of each '",unit_index,"' in the donor pool"),
                  caption = caption) +
    ggplot2::theme_minimal() +
    ggplot2::theme(legend.position="bottom")
}

generate_pop_vars <- function(){
  pref <- "pop_"
  race <- c("b", "w", "n")
  sex <- c("m", "f")
  age <- c("U20", "WA", "65o")
  out <- list()
  for(i in 1:length(race)){
    for(j in 1:length(sex)){
      for(k in 1:length(age)){
        out <- out %>% append(paste0(pref, race[i], sex[j], age[k]))
      }
    }
  }
  unlist(out)
}

generate_mean_predictors <- function(synth, var.list, b_time, i_time) {
  for(i in 1:length(var.list)){
    x <- sym(var.list[i])
    synth <- synth %>% generate_predictor(time_window=b_time:i_time, !!x := mean(!!x, na.rm=TRUE))
  }
  synth
}

generate_lag_predictors <- function(synth, lag.vars){
  ## parse lag.vars into two lists: var and year
  vars <- lag.vars %>% 
    sapply(str_split, "_") %>% 
    sapply("[[", 1) %>% 
    unname()
  
  years <- lag.vars %>% 
    sapply(str_split, "_") %>% 
    sapply("[[", 2) %>% 
    sapply(strtoi) %>% 
    unname()  
  # loop through vars and build the predictor
  for(i in 1:length(vars)){
    x <- sym(vars[i])
    y <- sym(lag.vars[i])
    synth <- synth %>% generate_predictor(time_window=years[i], !!y := !!x)
  }
  synth
}

synth.out <- function(df, dep.var, i_unit, i_time, mean.vars, lag.vars) {
  dep.var <- sym(dep.var) 
  
  b_time <- df %>% select(year) %>% min()
  synth <- df %>%
    # initial the synthetic control object
    synthetic_control(outcome = !!dep.var, # outcome
                      unit = state, # unit index in the panel data
                      time = year, # time index in the panel data
                      i_unit = i_unit, # unit where the intervention occurred
                      i_time = i_time, # time period when the intervention occurred
                      generate_placebos=TRUE # generate placebo synthetic controls (for inference)
    ) %>% 
    generate_mean_predictors(mean.vars, b_time, i_time) %>% 
    generate_lag_predictors(lag.vars) %>%
    generate_weights(optimization_window = b_time:i_time, margin_ipop = .02,sigf_ipop = 7,bound_ipop = 6 # optimizer options
    ) %>%
    # Generate the synthetic control
    generate_control()
}

generate_synth <- function(model, dep.var, mean.vars, lag.vars, dir.name, plots=FALSE, prune_level=2){
  
  if(model == "ca"){
    df <- read_csv(here("data/clean/working_data.csv")) %>% 
      filter(ca_model == 1)
    i_time <- 2015
    i_unit <- "California"
  } else if(model=="nc"){
    df <- read_csv(here("data/clean/working_data.csv")) %>% 
      filter(nc_model == 1)
    i_time <- 2014
    i_unit <- "North Carolina"
  }
  
  s <- synth.out(df, dep.var, i_unit, i_time, mean.vars, lag.vars)
  s %>% plot_trends()
  
  if(plots){
    s %>% plot_trends() 
    ggsave(here("figures/", paste0(dir.name, "/", model, "_", dep.var, "_trend.jpeg")), 
           width=7, height=7, units="in")
    s %>% plot_differences()
    ggsave(here("figures/", paste0(dir.name, "/", model, "_", dep.var, "_diff.jpeg")), 
           width=7, height=7, units="in")
    s %>% plot_weights()
    ggsave(here("figures/", paste0(dir.name, "/", model, "_", dep.var, "_weights.jpeg")), 
           width=7, height=7, units="in")
    s %>% plot_placeboos(prune_level = prune_level)
    ggsave(here("figures/", paste0(dir.name, "/", model, "_", dep.var, "_placebos.jpeg")), 
           width=7, height=7, units="in")
    }
}


######## Declare variables of interest ####################
### Note: the population variables follow the convention pop_bmAGE
### Where age is one of the following: U20, WA, 65o
###########################################################
dep.vars <- c("lab", "pov")

# mean vars are the predictors based on pretreatment mean
mean.vars.lab.ca <- c("rpcpi", "rpcgdp", "density", "pop_bf65o", "pop_nfWA", "pop_bfWA", "pop_nm65o")
mean.vars.pov.ca <- c("rpcpi", "rpcgdp", "density", "pop_bmU20", "pop_bfU20", "pop_bmWA", "pop_wm65o")
mean.vars.lab.nc <- c("rpcpi", "rpcgdp", "density", "pop_nfU20", "pop_nmU20", "pop_nf65o", "pop_nfWA")
mean.vars.pov.nc <- c("rpcpi", "rpcgdp", "density", "pop_nfU20", "pop_nmU20", "pop_nfWA", "pop_nmWA")


# lag vars are the predictors that match a specific year in the pre-treatment period
# use syntax "var_year"
lag.vars.lab.ca <- c("lab_2008", "lab_2011", "lab_2015")
lag.vars.pov.ca <- c("pov_2008", "pov_2011", "pov_2015")
lag.vars.lab.nc <- c("lab_2008", "lab_2011", "lab_2014")
lag.vars.pov.nc <- c("pov_2008", "pov_2011", "pov_2014")

####################### RUN EVERYTHING TO HERE ######################### 
####################### Then, Run Some Models ##########################
dir.name <- "0_refundable_trimed_prune_5"
generate_synth("ca", dep.vars[1], mean.vars.lab.ca, lag.vars.lab.ca, dir.name, plots = T, prune_level = 5)
generate_synth("nc", dep.vars[1], mean.vars.lab.nc, lag.vars.lab.nc, dir.name, plots = T, prune_level = 5)
generate_synth("ca", dep.vars[2], mean.vars.pov.ca, lag.vars.pov.ca, dir.name, plots = T, prune_level = 5)
generate_synth("nc", dep.vars[2], mean.vars.pov.nc, lag.vars.pov.nc, dir.name, plots = T, prune_level = 5)



# ## Optimal Mean Predictors for EITC Model ##
# mean.vars.lab.ca <- c("rpcpi", "rpcgdp", "density",  "pop_wfU20", "pop_wmU20")
# mean.vars.pov.ca <- c("rpcpi", "rpcgdp", "density", "pop_nf65o", "pop_wfWA")
# mean.vars.lab.nc <- c("rpcpi", "rpcgdp", "density", "pop_nmWA", "pop_nfWA", "pop_nmU20", "pop_nfU20")
# mean.vars.pov.nc <- c("rpcpi", "rpcgdp", "density", "pop_bf65o", "pop_bfU20", "pop_bfWA", "pop_bmU20")


### Optimal Mean Predictors for refundable EITC Model ##
# mean.vars.lab.ca <- c("rpcpi", "rpcgdp", "density", "pop_bf65o", "pop_nfWA", "pop_bfWA", "pop_nm65o")
# mean.vars.pov.ca <- c("rpcpi", "rpcgdp", "density", "pop_bmU20", "pop_bfU20", "pop_bmWA", "pop_wm65o")
# mean.vars.lab.nc <- c("rpcpi", "rpcgdp", "density", "pop_nfU20", "pop_nmU20", "pop_nf65o", "pop_nfWA")
# mean.vars.pov.nc <- c("rpcpi", "rpcgdp", "density", "pop_nfU20", "pop_nmU20", "pop_nfWA", "pop_nmWA")
