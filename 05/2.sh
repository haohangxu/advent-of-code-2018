#!/bin/bash

if [[ "$#" -ne 1 ]]; then
    echo "Usage: ./2.sh [filename]"
    exit 1
fi

if [[ ! -f $1 ]]; then
    echo "File does not exist: $1"
    exit 1
fi

pattern=""

for c in {a..z}; do
    pattern="$pattern|$c${c^^}|${c^^}$c"
done 

function react_without_unit () {
    cat $file | tr -d $unit | tr -d "${unit^^}" | sed -E -e ":loop;s/(${pattern:1})//g;tloop" | tr -d '\n' | wc -c
}

function react_without_each_unit () {
    for unit in {a..z}; do
	react_without_unit 
    done
}

fewest_units_left=$( react_without_each_unit | sort -n | head -n 1 )

echo "Best remaining: $fewest_units_left"
