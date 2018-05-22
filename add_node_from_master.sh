#!/bin/bash

print_help() {
  cat <<EOF
  use $0 docker_image add_node_begin_index add_node_end_index cpuset cpu_period cpu_quota memory disk_speed
EOF
}

if [ $# != 8 ]; then
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

/home/lyuxiaosu/add_node_with_weave.sh master $image $begin $end

#ssh lyuxiaosu@161.253.78.191 > /dev/null 2>&1 << eeooff

#/home/lyuxiaosu/add_node_with_weave.sh slave $begin $end

#eeooff


ssh lyuxiaosu@161.253.78.191 "/home/lyuxiaosu/add_node_with_weave.sh slave $image $begin $end $cpuset $cpu_period $cpu_quota $memory $disk_speed"

