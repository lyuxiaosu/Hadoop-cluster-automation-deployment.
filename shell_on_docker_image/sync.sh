#!/bin/bash

# sync all files to another machine 
path=$1
files=$(ls $path)
for filename in $files
do
	if [ -f $filename -a $filename != "hadoop-test.tar.gz" ]; then
		./scp.sh $filename
	fi
done
