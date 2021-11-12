#!/bin/bash

MAX_HOSTS_A_SWITCH=500
j=168
k=1

for i in $(seq 1 $MAX_HOSTS_A_SWITCH);
do
    addr1="192.$j.$k.1"
    addr2="192.$j.$k.2"
    echo $addr1
    sudo ip net exec host$i ping -c 1 $addr2
    sudo ip net exec host$(($MAX_HOSTS_A_SWITCH +$i)) ping -c 1 $addr1

    k=$(($k +1))
    if [ $(($i % 255)) -eq 0 ];
    then
        j=$(($j + 1))
        k=1
    fi
done
