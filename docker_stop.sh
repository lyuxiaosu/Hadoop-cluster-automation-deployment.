#!/bin/bash

docker stop master
docker rm master

begin=$1
end=$2
prefix="slave"
for ((i = $begin; i <= $end; i++))
do
        container="$prefix$i"
        docker stop $container
        docker rm $container
done


