#!/bin/bash
print_help() {
  cat <<EOF
  use $0 container_name
EOF
}

if [ $# != 1 ]; then
print_help
exit
fi


container_name=$1

docker exec -it $container_name sh -c 'rm -rf /root/hadoop-2.7.6/logs/userlogs/*'
