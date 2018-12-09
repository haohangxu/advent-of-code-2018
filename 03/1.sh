#!/bin/bash

if [[ "$#" -ne 1 ]]; then
    echo "Usage: ./1.sh [filename]"
    exit 1
fi

if [[ ! -f $1 ]]; then
    echo "File does not exist: $1"
    exit 1
fi

regex='#[0-9]+ @ ([0-9]+),([0-9]+): ([0-9]+)x([0-9]+)'

function print_coords () {
    top_x=${BASH_REMATCH[1]}
    top_y=${BASH_REMATCH[2]}
    width=${BASH_REMATCH[3]}
    height=${BASH_REMATCH[4]}
    
    for x in `seq $top_x $(( width + top_x - 1 ))`; do
	for y in `seq $top_y $(( height + top_y - 1 ))`; do
	    echo "$x $y"
	done
    done
}

function parse_and_print () {
    while IFS='' read -r line || [[ -n "$line" ]]; do
	if [[ $line =~ $regex ]]; then
	    echo "printing block ${BASH_REMATCH[0]}"
	    print_coords 
	else
	    echo "Found line that doesn't match regex! '$line'"
	    exit 1
	fi
    done < $1
}

num_lines=$( parse_and_print $1 | sort | uniq -c | awk '{print $1}' | egrep -v "^1$" | wc -l)
echo "Number of squares with more than one claim: $num_lines"
