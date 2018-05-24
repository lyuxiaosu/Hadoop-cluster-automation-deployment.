#!/bin/bash


print_help() {
  cat <<EOF
  use $0 master-slave/slave stop_node_begin_index stop_node_end_index 
EOF
}

if [ $# != 3 -a $# != 1 ]; then 
print_help
exit
fi

server_type=$1
begin=$2
end=$3

if [ $server_type = "master-slave" ]; then
	docker stop master
	docker rm master
	ssh lyuxiaosu@161.253.78.191 "/home/lyuxiaosu/docker_stop.sh $begin $end"
elif [ $server_type = "slave" ]; then
	ssh lyuxiaosu@161.253.78.191 "/home/lyuxiaosu/docker_stop.sh $begin $end"
	docker exec -d master /root/reset_master.sh
fi

