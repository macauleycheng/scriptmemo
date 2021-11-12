#!/bin/bash


MAX_SWITCHES=5
CTRL_IP=192.168.40.37

curl  -i -XPOST http://$CTRL_IP/mars/useraccount/v1/login --header 'Content-Type: application/json' --header 'Accept: application/json' -d  '{"user_name":"karaf", "password":"karaf"}' > session_temp

token=$(cat session_temp |grep MARS_G_SESSION_ID:|cut -d ":"  -f 2|tr -d '[:space:]')
echo $token


for i in $(seq 1 $MAX_SWITCHES);
  do
        ovs-vsctl del-br br$i > /dev/null
        datapath=$(printf "00000000000000%02x" $i)
        curl -H "Cookie: marsGSessionId=$token" -XDELETE http://$CTRL_IP/mars/v1/devices/of:$datapath
  done


for i in $(seq 1 $(($MAX_SWITCHES -1)));
  do
     ip link delete br$i-br$(($i+1))
     #ip link delete br$(($i+1))-br$i
  done 


MAX_HOSTS_A_SWITCH=500
for i in $(seq 1 $MAX_HOSTS_A_SWITCH);
do
  ip netns delete host$i
  ip netns delete host$(($MAX_HOSTS_A_SWITCH + $i))
  ip link delete host$i_leth
  ip link delete host$(($MAX_HOSTS_A_SWITCH + $i))_leth
done

ip link delete br1-br$(($MAX_SWITCHES))
ip link delete br$(($MAX_SWITCHES))-br1
