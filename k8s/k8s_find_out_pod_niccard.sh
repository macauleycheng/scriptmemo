#!/bin/bash

#echo "input POD name" $1

if [ -z $1 ]; then
        echo "Please input POD name"
        exit
fi

#find out container PID
container_pid=$(docker ps |grep $1 |grep -v 'POD'|cut -d ' ' -f 1|xargs docker inspect --format '{{.State.Pid}}')

#find out nic card
nic_card_no=$(sudo nsenter -t $container_pid -n ip address|grep @if|cut -d ':' -f 2| cut -d '@' -f 2|tr -dc '0-9')

#echo "nic card no" $nic_card_no

nic_card=$(ip link show |grep ^6:|cut -d ':' -f 2|cut -d '@' -f 1)

echo $nic_card
