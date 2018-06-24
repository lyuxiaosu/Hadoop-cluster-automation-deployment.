#!/bin/bash

print_help() {
  cat <<EOF
  use $0 add_node_begin_index add_node_end_index container_memory container_cpu_core block_size
EOF
}

if [ $# != 5 ]; then
print_help
exit
fi

begin=$1 #the begin index of the slaves
end=$2 # the end index of the slaves
memory=$3 # the memory size allocated for this container
cpu_core=$4 # the cpu core allocated for this container
block_size=$5 # hdfs block size

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

if [[ ("$last_letter" != "r" && $last_letter -ge $begin && $last_letter -le $end) ]]; then
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
		/root/generate_xml.sh $memory $cpu_core $block_size
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


/etc/init.d/ssh start -D 

