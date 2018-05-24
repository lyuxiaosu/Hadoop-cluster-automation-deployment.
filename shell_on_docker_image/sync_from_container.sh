#!/bin/bash

# sync files from a specified docker container

print_help() {
  cat <<EOF
  use $0 container_name 
EOF
}

if [ $# != 1 ]; then
print_help
exit
fi

container=$1
path=`pwd`
files=$(ls $path)
for filename in $files
do
        if [ -f $filename -a $filename != "hadoop-test.tar.gz" ]; then
                docker cp $container:/root/$filename ./
        fi
done

