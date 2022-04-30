##################################################
# Author: Scott Kjorlien
# Date: 4/29/2022
# Description: 
#     Take Census Poverty Survey data, clean it, and combine years into one file
##################################################


# TODO: the blueprint of the CSV for 2018 & 2019 includes more granular age 
# categories.... modify to handle those as well... 


# set up dir and file list
dir <- here("data/raw/Poverty")
f.list <- list.files(dir)
out <- data.frame()
i <- 10
# loop through files
for(i in 1:length(f.list)){
  
  # get the year of this file  
  fname.list <- str_extract(f.list[i], "[^.]*") %>% 
      str_split("-") %>% 
      unlist()
    year <- fname.list[2]
    
    #read in this dataset
    df <- read_csv(file.path(dir, f.list[i])) %>% 
      rename(group = `Label (Grouping)`) %>% 
      # select cols that have the estimate of interest
      select(group, contains("Percent below poverty level")) %>%
      # further select 'estimate' instead of 'standard error' 
      select(group, contains('Estimate'))
    
    
    # select rows that include the age groupings (can modify for other estimates.)
    # the specification of 2018+ years is different. handle 'em differently.
    if (year < 2018) { 
        df <- df[1:6, ]

    
        tdf <- df %>% 
          pivot_longer(contains("!!"), names_to = "state", values_to = "estimate") %>% 
          
          # clean up state names
          mutate(state = str_extract(state, "[^!!]*")) %>% 
          pivot_wider(id_cols=state, names_from = group, values_from = estimate) %>% 
          select(!AGE) %>% 
          select(!contains("Related"))
        
        # rename cols
        names(tdf) <- c("state", "total", "U18", "18to64", "65o")
    } else {
      df <- df[1:12, ]
      
      
      tdf <- df %>% 
        pivot_longer(contains("!!"), names_to = "state", values_to = "estimate") %>% 
        
        # clean up state names
        mutate(state = str_extract(state, "[^!!]*")) %>% 
        pivot_wider(id_cols=state, names_from = group, values_from = estimate) %>% 
        select(c(1, 2, 4, 8, 12)) 
    }
    names(tdf) <- c("state", "total", "U18", "18to64", "65o")
    
    # add year
    tdf$year <- year
    out <- rbind(out, tdf)
}

write_csv(out, here("data/clean/poverty_rates.csv"))