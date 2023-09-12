#!/bin/bash

if [ $# -ne 2 ]; then
    echo "Usage: $0 <profile_name> <output_file>"
    exit 1
fi

PROFILE=$1
OUTPUT_FILE=$2
TOKEN=""
OUTPUT=""

while true; do
    RESPONSE=$(aws-vault exec --duration=12h "$PROFILE" -- aws securityhub get-findings --region us-west-2 --next-token "$TOKEN")

    # Append to the consolidated output
    OUTPUT+="$RESPONSE"

    # Check if a NextToken exists in the response, indicating there are more findings to fetch
    TOKEN=$(echo "$RESPONSE" | jq -r ".NextToken")

    # Print out the token for debugging
    echo "NextToken: $TOKEN"

    # If no NextToken or it's 'null', then break out of the loop
    if [ -z "$TOKEN" ] || [ "$TOKEN" == "null" ]; then
        break
    fi

    # Sleep to prevent hitting the rate limit
    sleep 3
done

# Create a CSV file with date, profile name, and findings
echo "$OUTPUT" | jq -r '.Findings[] | select(.ProductArn | contains("securityhub")) | [.CreatedAt, .ProductArn, .Title, .Description, .Severity.Label, .Resources[].Type, .Resources[].Id, .Remediation.Recommendation.Text] | @csv' > "$OUTPUT_FILE"
echo "Data saved to $OUTPUT_FILE"
