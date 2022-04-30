**************************************
DATA GATHERING 
**************************************
All raw data stored in Box, clean data may be available in github if size permits.
copy the box file structure locally for everything to work. See "how-to" in data folder
Box Link: https://utexas.app.box.com/folder/162059819706

SEER Census Data:
    # Original txt file downloaded from: https://seer.cancer.gov/popdata/download.html
    # Data code available from: https://seer.cancer.gov/popdata/popdic.html
    # txt processed to csv using Python/parse_census_seer_txt_to_csv.py -> data/raw/SEER/census.csv
    # CSV cleaned & aggregated to state level using R/clean/clean_census.R -> data/clean/population.csv
    
Poverty Rate Data: 
    # Annual Poverty Status Data manually downloaded from: https://data.census.gov/cedsci/table?q=Poverty&g=0100000US%240400000&tid=ACSST1Y2010.S1701
    # cleaned using R/clean/clean_pov.R -> data/clean/poverty_rates.csv
    # I selected age groupings for poverty data, but the raw includes sex, race, employment status, work experience