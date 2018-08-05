#!/bin/bash

RANDOM=`date +%N|sed s/...$//`
number=$(( RANDOM % ($2 - $1 + 1 ) + $1 ))
echo $number
#awk -v min=$1 -v max=$2 'BEGIN{srand(); print int(min+rand()*(max-min+1))}'
