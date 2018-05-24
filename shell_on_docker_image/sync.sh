#!/bin/bash

# sync all files from another machine 
path=$1
files=$(ls $path)
for filename in $files
do
	if [ -f $filename -a $filename != "hadoop-test.tar.gz" ]; then
		./scp.sh $filename
	fi
done
