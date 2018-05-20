#!/bin/bash

if [ $HOSTNAME = "master" ]; then
	/usr/bin/expect >/dev/null 2>&1 <<EOF
	set timeout 20 
	spawn /root/hadoop-2.7.6/sbin/start-all.sh
	expect {
		"*yes/no" { send "yes\r"; exp_continue }	
	}
	expect eof	
EOF
fi
