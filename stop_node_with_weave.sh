#!/bin/bash


print_help() {
  cat <<EOF
  use $0 master/slave add_node_begin_index add_node_end_index 
EOF
}

if [ $# != 3 -a $# != 1 ]; then 
print_help
exit
fi

server_type=$1
begin=$2
end=$3

if [ $server_type = "master" ]; then
	docker stop master
	docker rm master
fi

ssh lyuxiaosu@161.253.78.191 "/home/lyuxiaosu/docker_stop.sh $begin $end"

