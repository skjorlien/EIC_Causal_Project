## DATA GATHERING 

All raw data stored in Box, clean data may be available in github if size permits.
copy the box file structure locally for everything to work. See "how-to" in data folder
Box Link: https://utexas.app.box.com/folder/162059819706

### SEER Census Data:
    - Original txt file downloaded from [SEER](https://seer.cancer.gov/popdata/download.html)
    - Data code available from: [SEER Data Dict](https://seer.cancer.gov/popdata/popdic.html)
    - txt processed to csv using Python/parse_census_seer_txt_to_csv.py -> data/raw/SEER/census.csv
    - CSV cleaned & aggregated to state level using R/clean/clean_census.R -> data/clean/population.csv
    
### Poverty Rate Data: 
    - Annual Poverty Status Data manually downloaded from [Census Poverty Survey](https://data.census.gov/cedsci/table?q=Poverty&g=0100000US%240400000&tid=ACSST1Y2010.S1701)
    - cleaned using R/clean/clean_pov.R -> data/clean/poverty_rates.csv
    - I selected age groupings for poverty data, but the raw includes sex, race, employment status, work experience

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
    poverty rates (3 different groups and state totals)
    labor force participation

    *Policy var:*
    dummy implemented or not.

    *controls:* 
    density
    demographics
    GDP per capita
    Lott & Mustard RPCs

## Next Steps: 
 ### Scott:
 - Get that data (check out iPUMS for poverty, labor force participation)
 
 ### Brandon:
 - Do that Lit Review


## Wish List? 
 - If this project yields interesting results neat: Augmented Synthetic Control Ridge ASCM
 - 


