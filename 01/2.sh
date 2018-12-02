#!/bin/bash

if [[ "$#" -ne 1 ]]; then
    echo "Usage: ./2.sh [filename]"
    exit 1
fi

if [[ ! -f $1 ]]; then
    echo "File does not exist: $1"
    exit 1
fi

# Keep track of seen frequencies
declare -A seen_frequencies

# test for existence
test1="bar"
test2="xyzzy"

if [[ ${array[$test1]} ]]; then echo "Exists"; fi    # Exists
if [[ ${array[$test2]} ]]; then echo "Exists"; fi    # doesn't
frequency=0

# Infinite loop. We'll exit inside the loop as soon as we find a duplicate.
while true ; do 
    while IFS='' read -r line || [[ -n "$line" ]]; do
	frequency=$(( frequency + line ))
	if [[ ${seen_frequencies[$frequency]} ]]; then
	    echo "First duplicate frequency: $frequency"
	    exit 0
	fi
	seen_frequencies[$frequency]=1
    done < $1
done
