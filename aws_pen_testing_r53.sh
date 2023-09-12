#!/bin/bash

query="SELECT z.account_id, r.account_id, r.name, r.type, r.records, r.alias_target FROM aws_all.aws_route53_zone AS z, aws_all.aws_route53_record AS r WHERE r.zone_id = z.id AND NOT z.private_zone"
output_file="output.csv"
chunk_size=200
offset=0

# Get the total number of records
total_records=$(steampipe query "SELECT COUNT(*) FROM ($query) AS count" --output csv | tail -n 1)

# Calculate the number of chunks
num_chunks=$(( (total_records + chunk_size - 1) / chunk_size ))

# Add headers to the output file
steampipe query "$query LIMIT 0" --output csv | head -n 1 > "$output_file"

# Process each chunk
for (( i=1; i<=num_chunks; i++ )); do
  echo "Processing chunk $i of $num_chunks..."

  # Execute the query with OFFSET and LIMIT
  chunk_query="$query OFFSET $offset LIMIT $chunk_size"
  steampipe query "$chunk_query" --output csv | tail -n +2 >> "$output_file"

  # Update the OFFSET
  offset=$((offset + chunk_size))
done

echo "Done! Results are in $output_file"
