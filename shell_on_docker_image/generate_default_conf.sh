#!/bin/bash

#this script is called by run_with_weave.sh 
print_help() {
  cat <<EOF
  use $0 am_memory am_cpu_core
EOF
}

if [ $# != 2 ]; then
print_help
exit
fi
 
memory=$1
cpu_core=$2
unit="m"

AM_memory=$(echo $memory*1024*0.8 | bc)
AM_memory=${AM_memory%.*}
map_memory=$AM_memory
reduce_memory=$map_memory

AM_cpu_core=$cpu_core
map_cpu_core=$AM_cpu_core
reduce_cpu_core=$map_cpu_core

map_heap=$(echo 0.8*$map_memory | bc)
map_heap=${map_heap%.*}
reduce_heap=$(echo 0.8*$reduce_memory | bc)
reduce_heap=${reduce_heap%.*}

#echo "AM_memory:$AM_memory map_memory:$map_memory reduce_memory:$reduce_memory map_heap:$map_heap reduce_heap:$reduce_heap"
cat > /root/hadoop-2.7.6/etc/hadoop/yarn-site.xml << EOF
<?xml version="1.0"?>
<!--
  Licensed under the Apache License, Version 2.0 (the "License");
  you may not use this file except in compliance with the License.
  You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

  Unless required by applicable law or agreed to in writing, software
  distributed under the License is distributed on an "AS IS" BASIS,
  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
  See the License for the specific language governing permissions and
  limitations under the License. See accompanying LICENSE file.
-->
<configuration>

	<property>
                <name>yarn.nodemanager.aux-services</name>
                <value>mapreduce_shuffle</value>
        </property>
        <property>
                <name>yarn.nodemanager.auxservices.mapreduce.shuffle.class</name>
                <value>org.apache.hadoop.mapred.ShuffleHandler</value>
        </property>
        <property>
                <name>yarn.resourcemanager.address</name>
                <value>master:8032</value>
        </property>
        <property>
                <name>yarn.resourcemanager.scheduler.address</name>
                <value>master:8030</value>
        </property>
        <property>
                <name>yarn.resourcemanager.resource-tracker.address</name>
                <value>master:8031</value>
        </property>
        <property>
                <name>yarn.resourcemanager.admin.address</name>
                <value>master:8033</value>
        </property>
        <property>
                <name>yarn.resourcemanager.webapp.address</name>
                <value>master:8088</value>
        </property>
        <property>
                <name>yarn.resourcemanager.scheduler.class</name>
                <value>org.apache.hadoop.yarn.server.resourcemanager.scheduler.fair.FairScheduler</value>
        </property>
	<property>
   		<name>yarn.nodemanager.vmem-check-enabled</name>
    		<value>false</value>
    		<description>Whether virtual memory limits will be enforced for containers</description>
  	</property>
 	<property>
   		<name>yarn.nodemanager.vmem-pmem-ratio</name>
    		<value>4</value>
    		<description>Ratio between virtual memory to physical memory when setting memory limits for containers</description>
  	</property>	
	
</configuration>

EOF

cat > /root/hadoop-2.7.6/etc/hadoop/mapred-site.xml << EOF
<?xml version="1.0"?>
<?xml-stylesheet type="text/xsl" href="configuration.xsl"?>
<!--
  Licensed under the Apache License, Version 2.0 (the "License");
  you may not use this file except in compliance with the License.
  You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

  Unless required by applicable law or agreed to in writing, software
  distributed under the License is distributed on an "AS IS" BASIS,
  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
  See the License for the specific language governing permissions and
  limitations under the License. See accompanying LICENSE file.
-->

<!-- Put site-specific property overrides in this file. -->

<configuration>
	<property>
        	<name>mapreduce.framework.name</name>
        	<value>yarn</value>
        </property>
        <property>
        	<name>mapreduce.jobhistory.address</name>
        	<value>master:10020</value>
        </property>
        <property>
        	<name>mapreduce.jobhistory.webapp.address</name>
        	<value>master:19888</value>
        </property>
	<property>
		<name>yarn.app.mapreduce.am.resource.mb</name>
		<value>$AM_memory</value>
	</property>
	<property>
		<name>yarn.app.mapreduce.am.resource.cpu-vcores</name>
		<value>$AM_cpu_core</value>
	</property>
	
	<property>
		<name>mapreduce.map.memory.mb</name>
		<value>$map_memory</value>
	</property>
	<property>
		<name>mapreduce.reduce.memory.mb</name>
		<value>$reduce_memory</value>
	</property>
	<property>
		<name>mapreduce.map.java.opts</name>
		<value>-Xmx$map_heap$unit</value>
	</property>
	<property>
                <name>mapreduce.reduce.java.opts</name>
                <value>-Xmx$reduce_heap$unit</value>
        </property>
	<property>
		<name>mapreduce.map.cpu.vcores</name>
		<value>$map_cpu_core</value>
	</property>
	<property>
		<name>mapreduce.reduce.cpu.vcores</name>
		<value>$reduce_cpu_core</value>
	</property>
	
</configuration>
EOF
