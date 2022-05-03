df <- read.csv(here("data/state_demos.csv"))
pov <- read.csv(here("data/poverty_rates.csv"))

library(tidycensus)

fips_codes <- select(fips_codes, c("state", "state_code", "state_name"))
fips_codes <- rename(fips_codes, state_abr = "state")
fips_codes <- rename(fips_codes, state = "state_name")
pov_fips <- merge(x=pov, y = fips_codes, by="state")
pov_fips$state_code <- as.numeric(pov_fips$state_code)
pov_fips <- rename(pov_fips, fips = "state_code")
pov_fips <- select(pov_fips, !c("state", "state_abr"))

poverty <- pov_fips %>%
  unique() %>%
  filter(fips < 72) %>%
  rename(pov_tot = total,
         pov_u18 = U18,
         pov_18to64 = X18to64,
         pov_65o = X65o
           )

join <- merge(x=df, y=poverty, by=c("fips", "year"))  

write.csv(join,here("data/pov_demos_combined.csv"), row.names = FALSE)
