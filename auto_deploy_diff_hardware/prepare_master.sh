#!/bin/bash

#copy data file to master
output=`docker cp /dev/sue_test/xaa master:/root`
#create dirs
output=`docker exec -i master bash -c "/root/hadoop-2.7.6/bin/hdfs dfs -mkdir /user"`
output=`docker exec -i master bash -c "/root/hadoop-2.7.6/bin/hdfs dfs -mkdir /user/root"`
output=`docker exec -i master bash -c "/root/hadoop-2.7.6/bin/hdfs dfs -mkdir input"`

#upload data file to cluster
output=`docker exec -i master bash -c "/root/hadoop-2.7.6/bin/hdfs dfs -put /root/xaa input"`


