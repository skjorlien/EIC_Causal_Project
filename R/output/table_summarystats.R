

rm(list=ls())

read_csv("data/clean/working_data.csv") %>% 
  select(pov, lab, density, rpcgdp, rpcpi, contains("pop_")) %>% 
  as.data.frame() %>% 
  stargazer(type="latex", 
            summary=TRUE,
            label="tab:data_summary",
            out=file.path(here("tables"), "summarystats.tex"),
            digits = 2, digits.extra=1)


