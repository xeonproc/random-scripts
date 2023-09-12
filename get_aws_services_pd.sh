#!/bin/bash

DATE=$(date '+%Y-%m-%d')
FILENAME="services_aws_${DATE}.csv"
LIMIT=100

# Output the headers to the CSV file
echo "id,name,policy,team" > $FILENAME

OFFSET=0
MORE=true

while $MORE; do
  # Get the next page of results
  RESPONSE=$(curl --silent --location --request GET "https://api.pagerduty.com/services?query=aws-&include[]=escalation_policies&include[]=teams&limit=$LIMIT&offset=$OFFSET" \
  --header 'Accept: application/vnd.pagerduty+json;version=2' \
  --header 'Authorization: Token token=<YOUR TOKEN>')

  # Extract the services that contain 'aws-'
  echo $RESPONSE | jq -r '.services[] | select(.name | startswith("aws-")) | [.id, .name, .escalation_policy.summary, .teams[0].name] | @csv' >> $FILENAME

  # Check if there are more pages of results
  MORE=$(echo $RESPONSE | jq -r '.more')
  OFFSET=$(echo $RESPONSE | jq -r '.offset')
  OFFSET=$((OFFSET + LIMIT))
done
