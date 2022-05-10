##############################################
# Author: Scott Kjorlien
# Date: 4/30/2022
# Description: 
#   take the census csv, and aggregate populations by state, year, race, sex, and age group.
#   output a csv with the aggregated data
#
##############################################
rm(list=ls())

df <- read_csv(here("data/raw/SEER/demographics.csv")) %>% 
  mutate(pop = as.numeric(pop), 
    age_group = case_when(
      age == "00" ~ "U20",
      age == "01" ~ "U20",
      age == "02" ~ "U20",
      age == "03" ~ "U20",
      age == "04" ~ "U20",
      age == "05" ~ "WA",
      age == "06" ~ "WA",
      age == "07" ~ "WA",
      age == "08" ~ "WA",
      age == "09" ~ "WA",
      age == "10" ~ "WA",
      age == "11" ~ "WA",
      age == "12" ~ "WA",
      age == "13" ~ "WA",
      age == "14" ~ "65o",
      age == "15" ~ "65o",
      age == "16" ~ "65o",
      age == "17" ~ "65o",
      age == "18" ~ "65o"
  )) %>% 
  group_by(year, state, sfip, race, sex, age_group) %>% 
  summarize(pop = sum(pop))%>% 
  mutate(sex = case_when(
      sex == 1 ~ "m",
      sex == 2 ~ "f"
    ),
    race = case_when(
      race == 1 ~ "w",
      race == 2 ~ "b",
      race == 3 ~ "n"
    )) %>% 
  pivot_wider(id_cols = c(year, state, sfip), names_from = c(race, sex, age_group), 
              names_sep="", names_prefix = "pop_", values_from = pop)  %>% 
  filter(year >= 2007) %>% 
  rowwise() %>% 
  mutate(population = sum(c_across(contains("pop")))) %>% 
  write_csv(here("data/clean/population.csv"))
