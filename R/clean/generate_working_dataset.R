

rm(list=ls())

## Demographics
out.df <- read_csv(here("data/clean/population.csv")) %>% 
  mutate(across(contains("pop_"), ~ .x / population))


## GDP
tdf <- read_csv(here("data/clean/state_gdp.csv"))
out.df <- out.df %>% 
    left_join(tdf, by=c("sfip", "year")) %>% 
    mutate(rpcgdp = m_gdp*1000000/population) %>% 
    select(-state.y) %>% 
    rename("state_abbr" = state.x)

  
## Personal Income
tdf <- read_csv(here("data/clean/personal_income.csv"))
out.df <- out.df %>% 
  left_join(tdf, by=c("sfip", "year")) %>% 
  select(state, everything())


## Poverty and Labor
tdf <- read_csv(here("data/clean/povlab.csv"))
out.df <- out.df %>% 
  left_join(tdf, by=c("sfip", "year")) %>% 
  select(-State) %>% 
  filter(year<=2019)


## Create Density -- Note, You are losing DC intentionally here.
tmp_state <- data.frame(state.name, state.area) %>% 
  rename("state_name" = state.name, 
         "state_area" = state.area)

sfips <- fips_codes %>% 
  select(state_code, state_name) %>% 
  unique() %>% 
  left_join(tmp_state) %>% 
  drop_na() %>% 
  rename("sfip" = state_code)

out.df <- out.df %>% 
  left_join(sfips) %>% 
  select(-state_name) %>% 
  mutate(density = population/state_area) %>%
  filter(sfip != 11)

## join EITC info
tdf <- read_csv(here("data/clean/eitc_by_state.csv")) %>% 
  slice(1:51) %>% 
  select(state:eitc, -year_enacted)

out.df <- out.df %>% 
  left_join(tdf)
  
out.df <- out.df %>% 
  mutate(ca_model = ifelse((eitc == 0 | state == "California") & state != "North Carolina", 1, 0),
         nc_model = ifelse((refundable_eitc == 1 | state == "North Carolina") & state != "California", 1, 0))


write_csv(out.df, here("data/clean/working_data.csv"))

