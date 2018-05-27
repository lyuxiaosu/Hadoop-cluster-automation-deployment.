#!/bin/bash

print_help() {
  cat <<EOF
  use $0 container_name log_name
EOF
}

if [ $# != 2 ]; then
print_help
exit
fi


container_name=$1
log_name=$2

docker exec -i $container_name sh -c 'cd /root/hadoop-2.7.6/logs/userlogs/ ; tar -czvf logs.tar.gz ./*'
docker cp $container_name:/root/hadoop-2.7.6/logs/userlogs/logs.tar.gz /home/lyuxiaosu/ 
scp /home/lyuxiaosu/logs.tar.gz lyuxiaosu@161.253.78.192:/home/lyuxiaosu/logs/$log_name
rm -rf /home/lyuxiaosu/logs.tar.gz
