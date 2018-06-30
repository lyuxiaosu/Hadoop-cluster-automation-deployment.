#!/bin/bash

check_dataNode_started() {
	output=`docker exec -i master bash -c "/root/hadoop-2.7.6/bin/hdfs dfsadmin -report"`
	target_str="Live datanodes (3)"
	if [[ $output =~ "Live datanodes (3)" ]]; then
		echo "1"
	else 
		echo "0"
	fi
}
#copy data file to master
output=`docker cp /dev/sue_test/xaa master:/root`
#create dirs
output=`docker exec -i master bash -c "/root/hadoop-2.7.6/bin/hdfs dfs -mkdir /user"`
output=`docker exec -i master bash -c "/root/hadoop-2.7.6/bin/hdfs dfs -mkdir /user/root"`
output=`docker exec -i master bash -c "/root/hadoop-2.7.6/bin/hdfs dfs -mkdir input"`

isDataNodeStarted=`check_dataNode_started`
while [[ "$isDataNodeStarted" -eq 0 ]];
do
	echo "dataNodes not started, wait..."
	sleep 2
	isDataNodeStarted=`check_dataNode_started`
done

echo "dataNodes started, begin to upload data file to cluster"
#upload data file to cluster
output=`docker exec -i master bash -c "/root/hadoop-2.7.6/bin/hdfs dfs -put /root/xaa input"`


