#!/bin/bash


print_help() {
  cat <<EOF
  use $0 master/slave docker_image add_node_begin_index add_node_end_index cpuset cpu_period cpu_quota memory disk_speed 
EOF
}

if [ $# != 9 -a $# != 4 ]; then 
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

cpuset=$5
cpu_period=$6
cpu_quota=$7
memory=$8
disk_speed=$9
memory_unit="G"
disk_speed_unit="mb"

if [ $server_type = "slave" ]; then
	for ((i = 1; i < $begin; i++))
	do
        	container="$prefix$i"
        	docker exec -d $container /root/add_node_with_weave.sh $begin $end 0 
	done

	for ((i = $begin; i <= $end; i++))
	do
        	container="$prefix$i"
		memory_size="$memory$memory_unit"
		disk_speed_value="$disk_speed$disk_speed_unit"
		if [ $cpu_period = -1 -o $cpu_quota = -1 ]; then
			docker run -d --name $container -h $container --cpuset-cpus=$cpuset -m $memory_size \
										    --device-read-bps /dev/mapper/ECEVM01--vg-root:$disk_speed_value \
										    --device-write-bps /dev/mapper/ECEVM01--vg-root:$disk_speed_value \
										    $image /root/add_node_with_weave.sh $begin $end $memory
		else	
        		docker run -d --name $container -h $container --cpuset-cpus=$cpuset --cpu-period=$cpu_period --cpu-quota=$cpu_quota \
-m $memory_size --device-read-bps /dev/mapper/ECEVM01--vg-root:$disk_speed_value \
	--device-write-bps /dev/mapper/ECEVM01--vg-root:$disk_speed_value $image /root/add_node_with_weave.sh $begin $end $memory
		fi
		#add ip with weave
		tm=$[i + 2]
		ipaddr="$ip$tm$ip_suffix"
		weave attach $ipaddr $container
        	docker exec -d $container /root/start_node.sh $begin $end
	done

elif [ $server_type = "master" ]; then
	docker exec -d master /root/add_node_with_weave.sh $begin $end 0 
fi

