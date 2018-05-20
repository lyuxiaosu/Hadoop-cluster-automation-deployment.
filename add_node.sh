#!/bin/bash

begin=$1
end=$2
prefix="slave"

docker exec -d master /root/add_node.sh $begin $end

for ((i = 1; i < $begin; i++))
do
	container="$prefix$i"
	docker exec -d $container /root/add_node.sh $begin $end
done

for ((i = $begin; i <= $end; i++))
do
        container="$prefix$i"
	docker run -d --name $container -h $container -m 1G ubuntu:test /root/add_node.sh $begin $end
	docker exec -d $container /root/start_node.sh $begin $end
done




