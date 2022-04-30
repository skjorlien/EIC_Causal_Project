import os
import csv
import time

#######################################################
# Original txt file downloaded from: https://seer.cancer.gov/popdata/download.html
# Data code available from: https://seer.cancer.gov/popdata/popdic.html
#
#
# Elapsed time for full file (no LBOUND set): 4.5 mins
#######################################################

t1 = time.time()
data_map = {
    "year": (1, 4),
    "state": (5, 2),
    "sfip": (7, 2),
    "cfip": (9, 3),
    "registry": (12, 2),
    "race": (14, 1), 
    "origin": (15, 1),
    "sex": (16, 1),
    "age": (17, 2),
    "pop": (19, 8)
}
## If you turn off the LBOUND, set to 0. 
LBOUND=2000

def process_census_line(x):
    out = {}
    for key, pos in data_map.items():
        start = pos[0]-1
        end = pos[0] + pos [1] - 1
        out[key] = x[start:end] 
    return out

#change working dir
os.chdir(os.path.join(os.getcwd(), "data", "raw", "SEER"))

# read the txt line by line
txt_file = open("seer_census.txt")
fout = []
for line in txt_file:
    row = process_census_line(line)
    if int(row['year']) >= LBOUND:
        fout.append(row)


# save the list of dicts as csv
with open('census.csv', 'w', newline='') as output_file:
    dict_writer = csv.DictWriter(output_file, fout[0].keys())
    dict_writer.writeheader()
    dict_writer.writerows(fout)

t2 = time.time()

print( f"{(t2 - t1)/60:.2f} mins elapsed")