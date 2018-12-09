#!/bin/bash

if [[ "$#" -ne 1 ]]; then
    echo "Usage: ./1.sh [filename]"
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

result=$(cat $1 | sed -E -e ":loop;s/(${pattern:1})//g;tloop") 

# [wc -c] counts newlines.
echo "Resulting string of length $(echo $result | tr -d '\n' | wc -c)"
