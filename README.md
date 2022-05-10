## DATA GATHERING 

All raw data stored in Box, clean data may be available in github if size permits.
copy the box file structure locally for everything to work. See "how-to" in data folder
Box Link: https://utexas.app.box.com/folder/162059819706

### SEER Census Data:

- Original txt file downloaded from [SEER](https://seer.cancer.gov/popdata/download.html)
- Data code available from: [SEER Data Dict](https://seer.cancer.gov/popdata/popdic.html)
- txt processed to csv using Python/parse_census_seer_txt_to_csv.py -> data/raw/SEER/demographics.csv
- CSV cleaned & aggregated to state level using R/clean/clean_census.R -> data/clean/population.csv
    
### Poverty Rate Data & Labor Force participation: 

- Scraped ACS data via Census API using Python/scrape_census.py
- Cleaned data/raw/census_scrape/census_scrape_poverty_labor.csv -> data/clean/povlab.csv
- **Note: labor force participation limited to 2007 data**

### Real Per Capita Income & GDP
- Scraped from BEA using Python/scrape_bea.py -> data/raw/BEA/ real_gdp.csv, real_inc_per_cap.csv
- Cleaned real_inc_per_cap.csv -> data/clean/personal_income.csv
- Cleaned real_gdp.csv -> data/clean/state_gdp.csv

## Script Order:
### Prerequisites: 
- raw/SEER must have the seer_census.txt file

### Scrapers
- python/scrape_bea.py
- python/scrape_census.py

### Cleaners
- python/parse_census_seer_to_csv.py **must go first**
- R/clean/clean_census.R
- R/clean/clean_gdp.R
- R/clean/clean_personal_income.R
- R/clean/clean_povlab.R

### Aggregators
- R/clean/generate_working_dataset.R

### Analysis: 
All the magic happens in: R/output/synthetic_control.R


## Chat about the project 
### Brandon's Summary:

EITC - one of the most important anti-poverty measure. 
EITC expansion super important. politically palatable. Nat'l level goes in and out. 
Over the last 10 years, expansion or getting rid of
NC got rid 2014  -- was a pretty small amount 
CA expand 2017
More states expand in 2022

38 states have some form of EITC, 25 of them just give you that money. 
effect of EITC on poverty rates: 

### A Note on Vars

*Dependent vars:*
poverty rates (DONE)
labor force participation (DONE)

*Policy var:*
dummy implemented or not... is this even necessary? No but in some cases your control is
treated states and in some cases your control is untreated. 

*controls:* 
density (DONE)
demographics (DONE)
GDP per capita (DONE)
Lott & Mustard RPCs 
- rpcpi - real per capita Personal Income (DONE)
- rpcim - real per capita Income Maintenance 
- rpcui - real per capita Unemployment insurance
- rpcpo - real per capita retirement payments per person over 65

## Next Steps: 
 ### Scott:

- Join working_dataset.csv with brandon's file on EITC

 ### Brandon:

- Do that Lit Review


## Wish List? 

- If this project yields interesting results neat: Augmented Synthetic Control Ridge ASCM
 


