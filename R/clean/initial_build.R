my_data <- read.delim(here("data/us.1990_2020.19ages.adjusted.txt"), header = FALSE)

my_data <- my_data %>% 
  transform(year = substr(V1, 1,4), state = substr(V1, 5, 6), fips = substr(V1, 7, 8), 
            cfips = substr(V1, 9, 11), reg = substr(V1, 12, 13),  race = substr(V1, 14, 14),
            hisp = substr(V1, 15, 15), sex = substr(V1, 16, 16),  age = substr(V1, 17, 18),
            pop = substr(V1, 19, 26)) %>% 
  as.data.frame()

my_data$age <- as.numeric(my_data$age)
my_data$pop <- as.numeric(my_data$pop)
my_data$race <- as.numeric(my_data$race)
my_data$hisp <- as.numeric(my_data$hisp)
my_data$sex <- as.numeric(my_data$sex)


my_data <- my_data %>% 
  select(!c("V1", "cfips", "reg"))

my_data <- my_data %>% 
  mutate(r = case_when(
    race == 1 ~ "w",
    race == 2 ~ "b",
    race > 2 ~ "o"
  )) %>% 
  mutate(h = case_when(
    hisp == 0 ~ "n",
    hisp == 1 ~ "h"
  )) %>% 
  mutate(s = case_when(
    sex == 1 ~ "m",
    sex == 2 ~ "f"
  )) %>% 
  mutate(a = case_when(
    age < 5 ~ "U18",
    age > 4 & age < 15 ~ "18to64",
    age > 14 ~ "65o"
  ))


df <- my_data %>% 
  unite("demographic", r:a) %>% 
  select(!c("race","hisp","sex", "age")) %>% 
  filter(year > 2009 & year < 2020)
  
write.csv(df,here("data/seer_clean.csv"), row.names = FALSE)

