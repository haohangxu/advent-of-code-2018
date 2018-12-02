#!/bin/bash

if [[ "$#" -ne 1 ]]; then
    echo "Usage: ./1.sh [filename]"
    exit 1
fi

if [[ ! -f $1 ]]; then
    echo "File does not exist: $1"
    exit 1
fi

num_with_double=0
num_with_triple=0

while IFS='' read -r line || [[ -n "$line" ]]; do
    counts=$(echo $line | grep -o . | sort | uniq -c | awk '{print $1}' | sort | uniq)
    # This isn't great, as it only works if there are no letters that
    # appear more than 10 times. 
    if echo $counts | grep "2"; then
	num_with_double=$(( num_with_double + 1 ))
    fi    
    if echo $counts | grep "3"; then
	num_with_triple=$(( num_with_triple + 1 ))
    fi    
done < $1

echo "Checksum = $(( num_with_triple * num_with_double ))"
