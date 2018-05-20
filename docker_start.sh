#!/bin/bash
docker run -d --name master -h master -m 4G ubuntu:test /root/run.sh $1 $2

begin=$1
end=$2
prefix="slave"
for ((i = $begin; i <= $end; i++))
do
        container="$prefix$i"
        docker run -d --name $container -h $container -m 1G ubuntu:test /root/run.sh $1 $2
done

docker exec -d master /root/start_master.sh


