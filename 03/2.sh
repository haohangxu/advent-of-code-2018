#!/bin/bash

if [[ "$#" -ne 1 ]]; then
    echo "Usage: ./2.sh [filename]"
    exit 1
fi

if [[ ! -f $1 ]]; then
    echo "File does not exist: $1"
    exit 1
fi

regex='#([0-9]+) @ ([0-9]+),([0-9]+): ([0-9]+)x([0-9]+)'

function print_coords () {
    id=${BASH_REMATCH[1]}
    top_x=${BASH_REMATCH[2]}
    top_y=${BASH_REMATCH[3]}
    width=${BASH_REMATCH[4]}
    height=${BASH_REMATCH[5]}
    
    for x in `seq $top_x $(( width + top_x - 1 ))`; do
	for y in `seq $top_y $(( height + top_y - 1 ))`; do
	    echo "$id $x $y"
	done
    done
}

function parse_and_print () {
    while IFS='' read -r line || [[ -n "$line" ]]; do
	if [[ $line =~ $regex ]]; then
	    print_coords 
	else
	    echo "Found line that doesn't match regex! '$line'"
	    exit 1
	fi
    done < $1
}

squares=$(parse_and_print $1)
unique_squares=$(echo "$squares" | sort -k2 | uniq -c -f 1 | egrep "^[ ]+1 " | awk '{print $2}' | sort -n | uniq -c | sort)
all_squares=$(echo "$squares" | awk '{print $1}' | sort -n | uniq -c | sort)
claims_with_unique_squares=$(comm -12 <(echo "$unique_squares") <(echo "$all_squares") | awk '{print $2}')

echo "Claims with unique squares: $claims_with_unique_squares"
