#!/bin/bash
print_help() {
  cat <<EOF
  use $0 docker_image memory cpu_core block_size
EOF
}

if [ $# != 4 ]; then
print_help
exit
fi

image=$1
memory=$2
cpu_core=$3
block_size=$4

docker run -d --name master -h master -m 4G $image /root/run_with_weave.sh $memory $cpu_core $block_size 2 1
weave attach 192.168.0.2/24 master
docker exec -d master /root/start_master.sh


