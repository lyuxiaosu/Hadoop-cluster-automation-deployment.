#!/bin/bash


print_help() {
  cat <<EOF
  use $0 master/slave docker_image add_node_begin_index add_node_end_index 
EOF
}

if [ $# != 4 ]; then 
print_help
exit
fi

server_type=$1
image=$2
begin=$3
end=$4
prefix="slave"
ip="192.168.0."
ip_suffix="/24"

if [ $server_type = "slave" ]; then
	for ((i = 1; i < $begin; i++))
	do
        	container="$prefix$i"
        	docker exec -d $container /root/add_node_with_weave.sh $begin $end
	done

	for ((i = $begin; i <= $end; i++))
	do
        	container="$prefix$i"
        	docker run -d --name $container -h $container -m 1G $image /root/add_node_with_weave.sh $begin $end
		#add ip with weave
		tm=$[i + 2]
		ipaddr="$ip$tm$ip_suffix"
		weave attach $ipaddr $container
        	docker exec -d $container /root/start_node.sh $begin $end
	done

elif [ $server_type = "master" ]; then
	docker exec -d master /root/add_node_with_weave.sh $begin $end
fi


