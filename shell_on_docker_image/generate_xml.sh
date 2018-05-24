#!/bin/bash

#this script is called by add_node_with_weave.sh 
memory=$1
unit="m"
#if [ $physic_memory -eq 2 ]; then
	#mb_memory=2048
#elif [ $physic_memory -gt 2 ]; then
	#num=1024
	#mb_memory=$(($num*$physic_memory))
#fi

physic_memory=$((1024*$memory))
NM_resource_memory=$(echo 0.8*$physic_memory | bc)
#get int part
NM_resource_memory=${NM_resource_memory%.*}
NM_scheduler_maximum=$NM_resource_memory
NM_scheduler_minimum=32

if [ $memory -eq 2 ]; then
	AM_map_memory=768 
	AM_reduce_memory=1024
elif [ $physic_memory -gt 2 ]; then
	AM_map_memory=1024
	AM_reduce_memory=$((2*$AM_map_memory))
fi

AM_resource_memory=$AM_reduce_memory
AM_map_heap=$(echo 0.8*$AM_map_memory | bc)
AM_map_heap=${AM_map_heap%.*}
AM_reduce_heap=$(echo 0.8*$AM_reduce_memory | bc)
AM_reduce_heap=${AM_reduce_heap%.*}

#echo "NM_resource_memory:$NM_resource_memory NM_scheduler_maximum:$NM_scheduler_maximum NM_scheduler_minimum:$NM_scheduler_minimum: AM_map_memory:$AM_map_memory AM_reduce_memory:$AM_reduce_memory AM_resource_memory:$AM_resource_memory AM_map_heap:$AM_map_heap AM_reduce_heap:$AM_reduce_heap"
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
                <name>yarn.nodemanager.resource.memory-mb</name>
                <value>$NM_resource_memory</value>
        </property>
	<property>
		<name>yarn.scheduler.maximum-allocation-mb</name>
		<value>$NM_scheduler_maximum</value>
	</property>
	<property>
                <name>yarn.scheduler.minimum-allocation-mb</name>
                <value>$NM_scheduler_minimum</value>
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
		<value>$AM_resource_memory</value>
	</property>
	<property>
		<name>mapreduce.map.memory.mb</name>
		<value>$AM_map_memory</value>
	</property>
	<property>
		<name>mapreduce.reduce.memory.mb</name>
		<value>$AM_reduce_memory</value>
	</property>
	<property>
		<name>mapreduce.map.java.opts</name>
		<value>-Xmx$AM_map_heap$unit</value>
	</property>
	<property>
                <name>mapreduce.reduce.java.opts</name>
                <value>-Xmx$AM_reduce_heap$unit</value>
        </property>
	
</configuration>
EOF