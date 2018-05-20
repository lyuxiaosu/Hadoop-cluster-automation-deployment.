#!/bin/bash
echo "192.168.0.2 master" > /etc/hosts
> /root/hadoop-2.7.6/etc/hadoop/slaves

begin=$1 #the begin index of the slaves
end=$2 # the end index of the slaves
ip="192.168.0."
suffix=" slave"
prefix_host="slave"
for ((i = $begin; i <= $end; i++))
do
        tm=$[i + 2]
        host_str="$ip$tm$suffix$i"
        echo $host_str >> /etc/hosts
        host="$prefix_host$i"
        echo $host >> /root/hadoop-2.7.6/etc/hadoop/slaves
done


sed_pre="s/root@.*$/root@"
sed_suff="/g"
for ((i = $begin; i <= $end; i++))
do
        tm=$[i + 2]
        ipaddr="$ip$tm"
        host="$prefix_host$i"
        if [ $HOSTNAME = "master" ]; then
                sed -i 's/root@.*$/root@master/g' /root/.ssh/authorized_keys
        elif [ $HOSTNAME = $host ]; then
                sed_str="$sed_pre$host$sed_suff"
                sed -i $sed_str /root/.ssh/authorized_keys
        fi

done
/etc/init.d/ssh start -D


