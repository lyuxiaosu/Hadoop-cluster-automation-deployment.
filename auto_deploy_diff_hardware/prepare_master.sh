#!/bin/bash

workload_size=$1
check_dataNode_started() {
	output=`docker exec -i master bash -c "/root/hadoop-2.7.6/bin/hdfs dfsadmin -report"`
	target_str="Live datanodes (3)"
	if [[ $output =~ "Live datanodes (3)" ]]; then
		echo "1"
	else 
		echo "0"
	fi
}
#split test file to the size of workload_size
workload_size=$(echo $workload_size*1024*1024| bc)
pushd /home/lyuxiaosu/test/
rm -rf xaa
split -b $workload_size /home/lyuxiaosu/test/testfile.txt
mv xaa sample
rm -rf x*
mv sample xaa
popd

#copy data file to master
output=`docker cp /home/lyuxiaosu/test/xaa master:/root`
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


