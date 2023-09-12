import os
import matplotlib.pyplot as plt
import pandas as pd
from fpdf import FPDF
from datetime import datetime
import re

directory = '/Users/senff/OneDrive - Hewlett Packard Enterprise/scripts/redstone_test_script/steampipe-mod-aws-compliance/sec-hub-runs/'+datetime.today().strftime('%Y-%m-%d')
 
# iterate over files in
# that directory
for filename in os.listdir(directory):
    f = os.path.join(directory, filename)
    # checking if it is a file
    if os.path.isfile(f):
        print(f)
        data = pd.read_csv(f)

        df = pd.DataFrame(data, columns= ['severity','title','control_title'])

        dups_severity = df.pivot_table(columns=['severity'], aggfunc='size')
        dups_title = df.pivot_table(columns=['title'], aggfunc='size')
        dups_control = df.pivot_table(columns=['control_title'], aggfunc='size')

        fig, ax = plt.subplots(2, 1, figsize=(18,16))
        dups_severity.plot(kind='barh', ax=ax[0])
        dups_title.plot(kind='barh', ax=ax[1])

        #plt.show()
        plt.savefig(f.replace('.csv','')+'.pdf')