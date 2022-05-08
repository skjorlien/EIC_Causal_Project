import requests
import pandas as pd
import os 

BASE_URL = "https://api.census.gov/data"
KEY = None 
ACS = "acs/acs1/profile"
GEOG = "state:*"


def scrape_census(year, **kwargs):
    url = f"{BASE_URL}/{year}/{ACS}"
    varstr = ""
    for key, value in kwargs.items(): 
        varstr += f"{value},"
    varstr = varstr[:-1]
    params = {
        'get': varstr,
        'for': GEOG
    }
    r = requests.get(url, params=params)
    l = len(r.json())
    df = pd.DataFrame(r.json()[1:l], columns=r.json()[0])
    df['year'] = year
    for key, val in kwargs.items():
        df.rename(columns={val: key}, inplace=True)
    return df


if __name__ == "__main__":
    pov_vars = {
        2005: "DP03_0094E", 
        2006: "DP03_0094E", 
        2007: "DP03_0096E", 
        2008: "DP03_0096E", 
        2009: "DP03_0103E", 
        2010: "DP03_0119PE" 
    }
    lab_vars = {
        2005: "DP03_0002E",
        2006: "DP03_0002E",
        2007: "DP03_0002PE"
    }
    kwargs = {
        'State': "NAME",
    }

    df = None
    for year in range(2007, 2020):
        # grab the right code for pov var
        if year < 2010:
            kwargs['pov'] = pov_vars[year]
        else: 
            kwargs['pov'] = pov_vars[2010]

        # Grab the right code for lab var
        if year > 2007:
            kwargs['lab'] = lab_vars[2007]
        else:
            kwargs['lab'] = lab_vars[year]

        # scrape
        if df is None:
            df = scrape_census(year, **kwargs)
        else:
            tdf = scrape_census(year, **kwargs)
            df = df.append(tdf)
    
    # save it down
    os.chdir(os.path.join(os.getcwd(), "data", "raw", "census_scrape"))
    df.to_csv(os.path.join(os.getcwd(), "census_scrape_poverty_labor.csv"))