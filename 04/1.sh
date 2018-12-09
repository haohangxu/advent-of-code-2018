#!/bin/bash

if [[ "$#" -ne 1 ]]; then
    echo "Usage: ./1.sh [filename]"
    exit 1
fi

if [[ ! -f $1 ]]; then
    echo "File does not exist: $1"
    exit 1
fi

time_regex="\[([0-9]{4}-[0-9]{2}-[0-9]{2}) ([0-9]{2}):([0-9]{2})\]"
guard_regex="$time_regex Guard #([0-9]+) begins shift"
asleep_regex="$time_regex falls asleep"
wake_regex="$time_regex wakes up"

# print_asleep_minutes_same_day
# $1 = GUARD
# $2 = START_MIN
# $3 = END_MIN
function print_asleep_minutes_same_day () {
    end_min_local=$3
    for i in `seq $2 $(( 10#$end_min_local - 1 ))`; do
	echo "$i $1"
    done
}

# print_asleep_minutes 
# $1 = GUARD 
# $2 = START_DAY
# $3 = START_HR
# $4 = START_MIN
# $5 = END_DAY
# $6 = END_HR
# $7 = END_MIN
function print_asleep_minutes () {
    guard=$1
    start_day=$2
    start_hr=$3
    start_min=$4
    end_day=$5
    end_hr=$6
    end_min=$7

    if [[ $end_day == $start_day ]]; then 
	if [[ $start_hr == "00" ]]; then
	    if [[ $end_hr == "00" ]]; then
		print_asleep_minutes_same_day $guard $start_min $end_min
	    else
		print_asleep_minutes_same_day $guard $start_min 60
	    fi
	else
	    # This is an impossible case, theoretically, since if the
	    # day is the same and the start hour is not 00, then the
	    # end hour cannot be 00.
	    if [[ $end_hr == "00" ]]; then
		print_asleep_minutes_same_day $guard 0 $end_min
	    fi
	    # Otherwise, no qualifying minutes.
	fi
    else
	total_days_touched=$(( ($(date --date=$end_day +%s) - $(date --date=$start_day +%s) )/(60*60*24) + 1))
	
	if [[ $start_hr == "00" ]]; then
	    if [[ $end_hr == "00" ]]; then
		print_asleep_minutes_same_day $guard $start_min 60
		print_asleep_minutes_same_day $guard 0 $end_min
		for i in `seq 1 $(( total_days_touched - 2 ))`; do
		    print_asleep_minutes_same_day $guard 0 60
		done
	    else
		print_asleep_minutes_same_day $guard $start_min 60
		for i in `seq 1 $(( total_days_touched - 1 ))`; do
		    print_asleep_minutes_same_day $guard 0 60
		done		
	    fi
	else
	    if [[ $end_hr == "00" ]]; then
		print_asleep_minutes_same_day $guard 0 $end_min
		for i in `seq 1 $(( total_days_touched - 2 ))`; do
		    print_asleep_minutes_same_day $guard 0 60
		done
	    else
		for i in `seq 1 $(( total_days_touched - 2))`; do
		    print_asleep_minutes_same_day $guard 0 60
		done		
	    fi
	fi	
    fi
}

function parse_and_print () {
    guard=0
    awake=false
    previous_day=0
    previous_hr=0
    previous_min=0

    while IFS='' read -r line || [[ -n "$line" ]]; do
	if [[ $line =~ $guard_regex ]]; then
	    day=${BASH_REMATCH[1]}
	    hr=${BASH_REMATCH[2]}
	    min=${BASH_REMATCH[3]}
	    new_guard=${BASH_REMATCH[4]}

	    # If guard shift changes, we need to account for the
	    # previous guard's asleep minutes.
	    if ! $awake; then 
		print_asleep_minutes $guard $previous_day $previous_hr $previous_min $day $hr $min
	    fi

	    guard=$new_guard
	    awake=true
	    previous_day=$day
	    previous_hr=$hr
	    previous_min=$min

	elif [[ $line =~ $asleep_regex ]]; then
	    day=${BASH_REMATCH[1]}
	    hr=${BASH_REMATCH[2]}
	    min=${BASH_REMATCH[3]}

	    # This is theoretically impossible, as it is impossible to
	    # fall asleep when already asleep.
	    if ! $awake; then
		print_asleep_minutes $guard $previous_day $previous_hr $previous_min $day $hr $min
	    fi

	    awake=false
	    previous_day=$day
	    previous_hr=$hr
	    previous_min=$min

	elif [[ $line =~ $wake_regex ]]; then
	    day=${BASH_REMATCH[1]}
	    hr=${BASH_REMATCH[2]}
	    min=${BASH_REMATCH[3]}

	    if ! $awake; then
		print_asleep_minutes $guard $previous_day $previous_hr $previous_min $day $hr $min
	    fi

	    awake=true
	    previous_day=$day
	    previous_hr=$hr
	    previous_min=$min
	else
	    exit 1
	fi
    done < $1

    if ! $awake && [[ $previous_hr == "00" ]]; then
	print_asleep_minutes_same_day $guard $previous_min 60
    fi
}

sorted_file_name="$1.tmp-$(date +'%s')"
sort $1 > $sorted_file_name
asleep_record=$(parse_and_print $sorted_file_name | sort -k2)
sleepiest_guard=$(echo "$asleep_record" | uniq -c -f 1 | sort -k1 -rn | head -n 1 | awk '{print $3}')
sleepiest_minute=$(echo "$asleep_record" | egrep "$sleepiest_guard$" | uniq -c | sort -k1 -rn | head -n 1 | awk '{print $2}')

echo "sleepiest_guard = $sleepiest_guard"
echo "sleepiest_minute = $sleepiest_minute"

rm $sorted_file_name
