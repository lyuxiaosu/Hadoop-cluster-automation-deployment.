#!/bin/bash
docker run -d --name master -h master -m 4G ubuntu:test /root/run_with_weave.sh 2 1

docker exec -d master /root/start_master.sh


