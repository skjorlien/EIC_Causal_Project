seer <- read.csv(here("data/seer_clean.csv"))

pops <- seer %>%
  group_by(year, state, fips, demographic) %>%
  summarize(population = sum(pop))
  mutate(row = row_number()) %>%
  tidyr::pivot_wider(names_from = demographic, values_from = pop) %>%
  select(-row)
  
pop_rot <- pops %>%
  group_by(year, state, fips) %>%
  pivot_wider(names_from = demographic, values_from = population)

write.csv(pop_rot,here("data/state_demos.csv"), row.names = FALSE)
