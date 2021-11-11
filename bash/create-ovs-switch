#!/bin/bash


MAX_SWITCHES=50
CTRL_IP=192.168.40.37
j=0

for i in $(seq 1 $MAX_SWITCHES);
  do
        ovs-vsctl add-br br$i
        ovs-vsctl set bridge br$i protocols=OpenFlow13
        ovs-vsctl set-controller br$i tcp:$CTRL_IP:6653
        datapath=$(printf "00000000000000%02x" $i)
        echo $datapath br$i
        ovs-vsctl set bridge br$i other-config:datapath-id=$datapath
  done

curl  -i -XPOST http://$CTRL_IP/mars/useraccount/v1/login --header 'Content-Type: application/json' --header 'Accept: application/json' -d  '{"user_name":"karaf", "password":"karaf"}' > session_temp

token=$(cat session_temp |grep MARS_G_SESSION_ID:|cut -d ":"  -f 2|tr -d '[:space:]')
echo $token

for i in $(seq 1 $MAX_SWITCHES);
  do
    datapath=$(printf "00000000000000%02x" $i)
    mac=$(printf "00-00-00-00-00-%02x" $i)
    echo $datapath $mac
    curl  -H "Cookie: marsGSessionId=$token"  -X POST --header 'Content-Type: application/json' --header 'Accept: application/json' -d "{ \"id\": \"of:$datapath\", \"name\":\"br$i\", \"type\": \"leaf\",\"available\": true, \"mgmtIpAddress\": \"192.168.40.31\", \"port\":80, \"mac\": \"$mac\", \"nos\": \"of\", \"protocol\": \"of\",\"rack_id\": \"1\", \"defautCfg\": false}" http://$CTRL_IP:8181/mars/v1/devices
  done
