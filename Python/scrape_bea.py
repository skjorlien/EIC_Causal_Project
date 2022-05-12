import requests
import os 
import pandas as pd

'''
API Documentation: https://apps.bea.gov/api/_pdf/bea_wBEAeb_service_api_user_guide.pdf
'''

KEY = "3C0AF681-9E8B-4CCB-B508-19B8CD02FCE7"
BASE_URL =  "https://apps.bea.gov/api/data"

def scrape_bea(table, linecode = 1):
    url = f"{BASE_URL}"
    params = {
        'UserID': KEY,
        'ResultFormat': "JSON",
        'method': 'getdata',
        'datasetname': 'Regional',
        'TableName': table,
        'GeoFIPS': "STATE",
        'Year': "ALL",
        'LineCode': linecode
    }
    r = requests.get(url, params=params)
    df = pd.DataFrame(r.json()['BEAAPI']['Results']['Data'])
    return df

queries = {
    "real_inc_per_cap": {'data': 'SAINC1', 'linecode': 3},
    "real_gdp": {'data': "SAGDP9N", 'linecode': 1}
}

# linecode = 3
for query, params in queries.items():
    df = scrape_bea(params['data'], params['linecode'])
    df.to_csv(os.path.join(os.getcwd(), "data", "raw", "BEA", f"{query}.csv"))