#!/bin/bash

print_help() {
  cat <<EOF
  use $0 cluster_name slave_count
EOF
}

if [ $# != 2 ]; then
print_help
exit
fi

cluster_name=$1
slave_count=$2

clean_logs() {
	echo "start clean logs..."
	slave_count=$1

	for ((i = 1; i <= $slave_count; i++))
do
	container_name="slave"$i
	ssh lyuxiaosu@161.253.78.191 "/home/lyuxiaosu/auto_deploy_diff_hardware/clean_logs.sh $container_name"
done
	echo "clean logs done"
}

copy_logs() {
	echo "start copy logs..."
	if [ ! -d "/home/lyuxiaosu/logs" ]; then
		mkdir /home/lyuxiaosu/logs
	fi
	cluster_name=$1
	slave_count=$2
	application_name=$3
	for ((i = 1; i <= $slave_count; i++))
do
	tar_name=$cluster_name"_slave"$i"_"$application_name.tar.gz
        echo "$tar_name"
        container_name="slave"$i
	ssh lyuxiaosu@161.253.78.191 "/home/lyuxiaosu/auto_deploy_diff_hardware/collect_logs.sh $container_name $tar_name"
	
done
	echo "copy logs done"
}

output=`clean_logs $slave_count`
echo "$output"
#wordcount
echo "run wordcount..."
output=`docker exec -i master bash -c "/root/hadoop-2.7.6/bin/hdfs dfs -rm -r wordcount-output"`
echo "$output"
output=`docker exec -i master bash -c "/root/hadoop-2.7.6/bin/hadoop jar /root/hadoop-2.7.6/share/hadoop/mapreduce/hadoop-mapreduce-examples-2.7.6.jar wordcount input wordcount-output"`
echo "$output"
echo "wordcount finish"
application_name="wordcount"
output=`copy_logs $cluster_name $slave_count $application_name`
echo $output
output=`clean_logs $slave_count`
echo $output

#calculate pi
echo "run pi..."
output=`docker exec -i master bash -c "/root/hadoop-2.7.6/bin/hadoop jar /root/hadoop-2.7.6/share/hadoop/mapreduce/hadoop-mapreduce-examples-2.7.6.jar pi 100 100"`
echo "$output"
echo "pi finish"
application_name="pi"
output=`copy_logs $cluster_name $slave_count $application_name`
echo $output
output=`clean_logs $slave_count`
echo $output

#bbq
echo "run bbq"
output=`docker exec -i master bash -c "/root/hadoop-2.7.6/bin/hadoop jar /root/hadoop-2.7.6/share/hadoop/mapreduce/hadoop-mapreduce-examples-2.7.6.jar bbp 2 8 100 bbq"`
echo "$output"
echo "bbq finish"
application_name="bbq"
output=`copy_logs $cluster_name $slave_count $application_name`
echo $output
output=`clean_logs $slave_count`
echo $output

#wordmean
echo "run wordmean" 
output=`docker exec -i master bash -c "/root/hadoop-2.7.6/bin/hadoop jar /root/hadoop-2.7.6/share/hadoop/mapreduce/hadoop-mapreduce-examples-2.7.6.jar wordmean input wordmean-output"`
echo "$output"
echo "wordmean finish"
application_name="wordmean"
output=`copy_logs $cluster_name $slave_count $application_name`
echo $output
output=`clean_logs $slave_count`
echo $output

#wordmedian
echo "run wordmedian"
output=`docker exec -i master bash -c "/root/hadoop-2.7.6/bin/hadoop jar /root/hadoop-2.7.6/share/hadoop/mapreduce/hadoop-mapreduce-examples-2.7.6.jar wordmedian input wordmedian-output"`
echo "$output"
echo "wordmedian finish"
application_name="wordmedian"
output=`copy_logs $cluster_name $slave_count $application_name`
echo $output
output=`clean_logs $slave_count`
echo $output

#wordstandarddeviation
echo "run wordstandarddeviation"
output=`docker exec -i master bash -c "/root/hadoop-2.7.6/bin/hadoop jar /root/hadoop-2.7.6/share/hadoop/mapreduce/hadoop-mapreduce-examples-2.7.6.jar wordstandarddeviation input wordstandarddeviation-output"`
echo "$output"
echo "wordstandarddeviation finish"
application_name="wordstandarddeviation"
output=`copy_logs $cluster_name $slave_count $application_name`
echo $output
output=`clean_logs $slave_count`
echo $output
