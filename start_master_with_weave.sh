#!/bin/bash
print_help() {
  cat <<EOF
  use $0 docker_image
EOF
}

if [ $# != 1 ]; then
print_help
exit
fi

docker run -d --name master -h master -m 4G $1 /root/run_with_weave.sh 2 1
weave attach 192.168.0.2/24 master
docker exec -d master /root/start_master.sh


