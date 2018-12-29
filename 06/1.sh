#!/bin/bash

if [[ "$#" -ne 1 ]]; then
    echo "Usage: ./1.sh [filename]"
    exit 1
fi

if [[ ! -f $1 ]]; then
    echo "File does not exist: $1"
    exit 1
fi

max_x=$(awk -v max=0 'BEGIN { FS=", " } { max = (max > $1) ? max : $1 } END { print max }' $1)
max_y=$(awk -v max=0 'BEGIN { FS=", " } { max = (max > $2) ? max : $2 } END { print max }' $1)
min_x=$(awk -v min=$max_x 'BEGIN { FS=", " } { min = (min < $1) ? min : $1 } END { print min }' $1)
min_y=$(awk -v min=$max_y 'BEGIN { FS=", " } { min = (min < $2) ? min : $2 } END { print min }' $1)

function print_closest () { 
    awk_command='
function abs(v) { return v < 0 ? -v : v }
BEGIN { 
  FS=", "; 
  best="";
  best_count=0;
} 

{
  dist = abs(x - $1) + abs(y - $2)
  if (dist < min) { 
    min = dist
    best = $1", "$2
    best_count = 1
  }
  else if (dist == min) {
    best_count += 1
  }
}

END {
  if (best_count == 1) {
    print best
  }
}
'
    awk -v min=$(( max_x + max_y )) -v x=$2 -v y=$3 "$awk_command" $1
}

function print_all_closest () {
    for x in `seq $min_x $max_x`; do
	for y in `seq $min_y $max_y`; do
	    print_closest $1 $x $y
	done
    done
}

# greatest_area=$(print_all_closest $1 | egrep -v "^($min_x|$max_x)," | egrep -v " ($min_y|$max_y)$" | sort | uniq -c | sort -rn -k1 | head -1 | awk '{print $1}')

# echo "Greatest area = $greatest_area"

echo $min_x $max_x $min_y $max_y
