#!/bin/bash

if [[ "$#" -ne 1 ]]; then
    echo "Usage: ./1.sh [filename]"
    exit 1
fi

if [[ ! -f $1 ]]; then
    echo "File does not exist: $1"
    exit 1
fi

dependency_regex="Step ([A-Z]) must be finished"
step_regex="before step ([A-Z]) can begin\."
regex=$dependency_regex' '$step_regex

readarray conditions < $1

function print_all_steps () {
    for line in "${conditions[@]}"; do
	if [[ $line =~ $regex ]]; then
	    echo ${BASH_REMATCH[1]}
	    echo ${BASH_REMATCH[2]}
	fi
    done 
}

function print_next_step () {
    all_steps=$(print_all_steps | sort | uniq)
    if [ ${#all_steps[@]} -eq 0 ]; then
	# No steps left1
	echo "all steps completed"
	exit 0
    else
	for step in ${all_steps[@]}; do
	    condition="before step $step can begin"
	    pre_conditions=$(echo ${conditions[@]} | grep -c "$condition")
	    if [ $pre_conditions == 0 ] ; then
		echo $step
		return
	    fi
	done
    fi
}


print_next_step 
# Infinite loop. We'll exit inside the loop as soon as all steps are
# completed.
while true ; do
    conditions=( "${array[@]/$delete}" )
done

