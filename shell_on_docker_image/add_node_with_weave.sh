#!/bin/bash

print_help() {
  cat <<EOF
  use $0 add_node_begin_index add_node_end_index container_memory 
EOF
}

if [ $# != 3 ]; then
print_help
exit
fi

begin=$1 #the begin index of the slaves
end=$2 # the end index of the slaves
memory=$3 # the memory size allocated for this container
ip="192.168.0."
suffix=" slave"
prefix_host="slave"
sed_pre="s/root@.*$/root@"
sed_suff="/g"

for ((i = $begin; i <= $end; i++))
do
        tm=$[i + 2]
        ipaddr="$ip$tm"
        host="$prefix_host$i"
        if [ $HOSTNAME = $host ]; then
                sed_str="$sed_pre$host$sed_suff"
                sed -i $sed_str /root/.ssh/authorized_keys
        fi

done
last_letter=${HOSTNAME:0-1:1}

if [[ ($last_letter -ge $begin && $last_letter -le $end) ]]; then
	#This device is the new node to be added
	echo "192.168.0.2 master" > /etc/hosts
	> /root/hadoop-2.7.6/etc/hadoop/slaves

	for ((i = 1; i <= $end; i++))
	do
		tm=$[i + 2]
		host_str="$ip$tm$suffix$i"
		echo $host_str >> /etc/hosts
		host="$prefix_host$i"
		echo $host >> /root/hadoop-2.7.6/etc/hadoop/slaves
	done
fi

if [[ ($last_letter -lt $begin) || "$last_letter" = "r" ]]; then
	# This device is the node already existed on the cluster
	for ((i = $begin; i <= $end; i++))
	do
		tm=$[i + 2]
		host_str="$ip$tm$suffix$i"
		echo $host_str >> /etc/hosts
                host="$prefix_host$i"
                echo $host >> /root/hadoop-2.7.6/etc/hadoop/slaves
	done
fi

/root/generate_xml.sh $memory

/etc/init.d/ssh start -D 

