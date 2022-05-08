########################################
# Author: Scott Kjorlien
# Date: 5/8/2022
# Description: take the census scraped data for 
#       Poverty rates by state
#       labor force participation rates by state
#   clean it, output.
########################################


df <- read_csv(here("data/raw/census_scrape/census_scrape_poverty_labor.csv")) %>% 
  rename("sfip" = state) %>% 
  select(State, sfip, year, pov, lab) %>% 
  write_csv(here("data/clean/povlab.csv"))

