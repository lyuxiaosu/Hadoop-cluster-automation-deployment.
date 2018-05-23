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

docker run -d --name master -h master -m 2G $1 /root/run.sh 2 1

docker exec -d master /root/start_master.sh


