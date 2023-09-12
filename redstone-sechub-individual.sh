#!/bin/bash

#cat aws.spc and pull connection names to use for report runs in steampipe
#cat ~/.steampipe/config/aws.spc | grep "connection \"" | sed -e 's/connection "//g' -e 's/" {//g'

# remove old csv and output file   (containing account names from org)
rm *.csv
rm test.txt
#recreate output file for fresh account list
touch test.txt
#cleanup aws config profiles removing all but default so org script can repopulate latest profiles
sed -i .bak 3q /Users/senff/.aws/config
#assume granted default account to peform sync script update
yes | assume default
#run sync script to grab latest redstone accounts
cd /Users/senff/OneDrive\ -\ Hewlett\ Packard\ Enterprise/scripts && ./sync-aws.sh
cd ~/OneDrive\ -\ Hewlett\ Packard\ Enterprise/scripts/redstone_test_script/steampipe-mod-aws-compliance/
#parse aws profile removing everything but aws account name on each line outputting to output file
cat ~/.steampipe/config/aws.spc | grep "connection \"" | sed -e 's/connection "//g' -e 's/" {//g' > test.txt
#sleep to fix timing bug
sleep 2
#purge old results
rm results/*.csv
#params for output filie, and date of run
FILENAME="test.txt"
LINES=$(cat $FILENAME)
today=$(date +"%Y-%m-%d")
#cycle through outptuf file running steampipe compliance check against each account and output to CSV/HTTP/PDF with date/account-name in file
mkdir sec-hub-runs/${today}
for LINE in $LINES
do
    steampipe check aws_compliance.benchmark.foundational_security --search-path-prefix "$LINE" --export="results/$LINE".csv
    #steampipe check aws_compliance.benchmark.foundational_security --search-path-prefix "$LINE" --export="sec-hub-runs/results/$LINE".csv
    #steampipe check aws_compliance.benchmark.foundational_security --search-path-prefix "$LINE" --export="sec-hub-runs/${today}/$LINE"-${today}.html
done

for x in results/*.csv; do cp -i -- "$x" "sec-hub-runs/$today"; done

#add pyplot graph for every run
python3 metrics_test.py
python3 sev_sort.py
python3 status_removal.py