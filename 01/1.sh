#!/bin/bash

if [[ "$#" -ne 1 ]]; then
    echo "Usage: ./1.sh [filename]"
    exit 1
fi

if [[ ! -f $1 ]]; then
    echo "File does not exist: $1"
    exit 1
fi

frequency=$(awk 'BEGIN { sum=0 } { sum+=$1 } END {print sum }' $1)

echo "Resulting frequency: $frequency"
