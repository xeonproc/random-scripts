import pandas as pd
from pathlib import Path
from datetime import datetime

folder='/Users/senff/OneDrive - Hewlett Packard Enterprise/scripts/redstone_test_script/steampipe-mod-aws-compliance/sec-hub-runs/'+datetime.today().strftime('%Y-%m-%d')
for file in Path(folder).glob('*.csv'):
# Read the CSV file
    data = pd.read_csv(file)

    df = pd.DataFrame(data, columns= ['group_id', 'title', 'description',	'control_id', 'control_title', 'control_description','reason', 'resource', 'status', 'severity', 'account_id', 'region', 'aws_foundational_security', 'category', 'foundational_security_category', 'foundational_security_item_id', 'plugin', 'service', 'type'])
    df = df[df["status"].astype(str).str.contains("ok|skip") == False]
    df.to_csv(file, index=False)
    print(df)