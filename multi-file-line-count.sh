#!/bin/bash

# Check if the path argument is provided
if [ -z "$1" ]; then
    echo "Please provide the path to the files as an argument."
    exit 1
fi

path="$1"
file_pattern="*.csv"  # Change this to match your file pattern

total_lines=0

# Loop over the files matching the pattern in the specified path
for file in "$path/$file_pattern"; do
    lines=$(wc -l < "$file")
    total_lines=$((total_lines + lines))
done

echo "Total number of lines across the files: $total_lines"
