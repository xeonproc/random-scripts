import pandas as pd
from pathlib import Path
from datetime import datetime

folder='/Users/senff/OneDrive - Hewlett Packard Enterprise/scripts/redstone_test_script/steampipe-mod-aws-compliance/sec-hub-runs/'+datetime.today().strftime('%Y-%m-%d')
for file in Path(folder).glob('*.csv'):
# Read the CSV file
    data = pd.read_csv(file)

    # Configure the levels of severity
    levels = pd.Series({"critical" : 0, "high" : 1, "medium" : 2, "low" : 3})
    levels.name='severity'

    # Add numeric severity data to the table
    augmented = data.join(levels,on='severity',rsuffix='_')

    # Sort and select the original columns
    sorted_df = augmented.sort_values('severity_')[['group_id', 'title', 'description',	'control_id', 'control_title', 'control_description','reason', 'resource', 'status', 'severity', 'account_id', 'region', 'aws_foundational_security', 'category', 'foundational_security_category', 'foundational_security_item_id', 'plugin', 'service', 'type']]

    # Overwrite the original file
    sorted_df.to_csv(file, index=False)