#!/bin/bash

begin=$1 #the begin index of the slaves
end=$2 # the end index of the slaves

last_letter=${HOSTNAME:0-1:1}

if [[ ($last_letter -ge $begin && $last_letter -le $end) ]]; then
	source /root/hadoop-2.7.6/sbin/hadoop-daemon.sh start datanode
	source /root/hadoop-2.7.6/sbin/start-balancer.sh
	source /root/hadoop-2.7.6/sbin/yarn-daemon.sh start nodemanager
fi
