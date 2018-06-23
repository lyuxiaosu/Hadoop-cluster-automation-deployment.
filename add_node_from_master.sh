#!/bin/bash

print_help() {
  cat <<EOF
  use $0 docker_image add_node_begin_index add_node_end_index cpuset cpu_period cpu_quota memory disk_speed cpu_core
EOF
}

if [ $# != 9 ]; then
print_help
exit
fi

image=$1
begin=$2
end=$3

cpuset=$4
cpu_period=$5
cpu_quota=$6
memory=$7
disk_speed=$8
cpu_core=$9

/home/lyuxiaosu/add_node_with_weave.sh master $image $begin $end > add_node_with_weave.log

ssh lyuxiaosu@161.253.78.191 "/home/lyuxiaosu/add_node_with_weave.sh slave $image $begin $end $cpuset $cpu_period $cpu_quota $memory $disk_speed $cpu_core"

