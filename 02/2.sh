#!/bin/bash

if [[ "$#" -ne 1 ]]; then
    echo "Usage: ./2.sh [filename]"
    exit 1
fi

if [[ ! -f $1 ]]; then
    echo "File does not exist: $1"
    exit 1
fi

while IFS='' read -r line || [[ -n "$line" ]]; do
    for (( i=0; i<${#line}; i++ )); do
	matches=$( grep "${line:0:$i}.${line:$(( i + 1 ))}" $1 | grep -v $line )
	if [[ ! -z $matches ]]; then
	    # We've found it!
	    echo "Shared letters in correct boxes: ${line:0:$i}${line:$(( i + 1 ))}"
	    exit 0
	fi
    done
done < $1

echo "Shared boxes not found!"
