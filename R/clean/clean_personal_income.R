########################################
# Author: Scott Kjorlien
# Date: 5/8/2022
# Description: take the BEA scraped data for real income per capita,
#   clean it, join the fips codes and output.
########################################

sfips <- fips_codes %>% 
  select(state_code, state_name) %>% 
  unique()

df <- read_csv(here("data/raw/BEA/real_inc_per_cap.csv")) %>% 
  select(GeoName, TimePeriod, DataValue) %>% 
  rename("state" = GeoName, 
         "year" = TimePeriod,
         "rpcpi" = DataValue) %>% 
  mutate("state_name" = ifelse(str_detect(state, "\\*"), str_extract(state, "^.*(?=\\s)"), state)) %>% 
  left_join(sfips, by="state_name") %>%
  filter(year >= 2007) %>% 
  drop_na() %>% 
  select(state_name, state_code, year, rpcpi) %>% 
  rename("state" = state_name,
         "sfip" = state_code) %>% 
  write_csv(here("data/clean/personal_income.csv"))

