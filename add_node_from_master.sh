#!/bin/bash

print_help() {
  cat <<EOF
  use $0 docker_image add_node_begin_index add_node_end_index
EOF
}

if [ $# != 3 ]; then
print_help
exit
fi

image=$1
begin=$2
end=$3

/home/lyuxiaosu/add_node_with_weave.sh master $image $begin $end

#ssh lyuxiaosu@161.253.78.191 > /dev/null 2>&1 << eeooff

#/home/lyuxiaosu/add_node_with_weave.sh slave $begin $end

#eeooff


ssh lyuxiaosu@161.253.78.191 "/home/lyuxiaosu/add_node_with_weave.sh slave $image $begin $end"

