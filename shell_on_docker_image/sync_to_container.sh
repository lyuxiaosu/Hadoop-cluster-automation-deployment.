#!/bin/bash

# sync files to a specified docker container

print_help() {
  cat <<EOF
  use $0 file_name container_name
EOF
}

if [ $# != 2 ]; then
print_help
exit
fi

file=$1
container=$2
docker cp $file $container:/root/

