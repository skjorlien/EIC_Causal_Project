##############################################
# Author: Scott Kjorlien
# Date: 4/30/2022
# Description: 
#   take the census csv, and aggregate populations by state, year, race, sex, and age group.
#   output a csv with the aggregated data
##############################################
rm(list=ls())

df <- read_csv(here("data/raw/SEER/census.csv")) %>% 
  mutate(pop = as.numeric(pop)) %>% 
  group_by(year, state, race, sex, age) %>% 
  summarize(pop = sum(pop)) %>% 
  mutate(sex = case_when(
      sex == 1 ~ "m",
      sex == 2 ~ "f"
    ),
    race = case_when(
      race == 1 ~ "w",
      race == 2 ~ "b",
      race == 3 ~ "n"
    ),
    age = case_when(
      age == "00" ~ "0",
      age == "01" ~ "1-4",
      age == "02" ~ "5-9",
      age == "03" ~ "10-14",
      age == "04" ~ "15-19",
      age == "05" ~ "20-24",
      age == "06" ~ "25-29",
      age == "07" ~ "30-34",
      age == "08" ~ "35-39",
      age == "09" ~ "40-44",
      age == "10" ~ "45-49",
      age == "11" ~ "50-54",
      age == "12" ~ "55-59",
      age == "13" ~ "60-64",
      age == "14" ~ "65-69",
      age == "15" ~ "70-74",
      age == "16" ~ "75-79",
      age == "17" ~ "80-84",
      age == "18" ~ "85o"
    )) %>% 
  pivot_wider(id_cols = c(year, state), names_from = c(race, sex, age), 
              names_prefix = "pop_", values_from = pop) %>% 
  write_csv(here("data/clean/population.csv"))

