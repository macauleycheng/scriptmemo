#!/bin/bash


MAX_SWITCHES=3
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

#creat switch link
for i in $(seq 1 $(($MAX_SWITCHES -1)));
  do
          ip link add br$i-br$(($i+1)) type veth peer name br$(($i+1))-br$i
          ip link set br$i-br$(($i+1)) up
          ip link set br$(($i+1))-br$i up
          echo "add link br$i-br$(($i+1))"
          ovs-vsctl add-port br$i br$i-br$(($i+1))
          ovs-vsctl add-port br$(($i+1))  br$(($i+1))-br$i
  done

ip link add br1-br$(($MAX_SWITCHES)) type veth peer name br$(($MAX_SWITCHES))-br1
ip link set br1-br$(($MAX_SWITCHES)) up
ip link set br$(($MAX_SWITCHES))-br1 up
ovs-vsctl add-port br1 br1-br$(($MAX_SWITCHES))
ovs-vsctl add-port br$(($MAX_SWITCHES)) br$(($MAX_SWITCHES))-br1


echo "create host"
ip net add host1
ip net exec host1 ifconfig lo up
#use below to enter namespace, it will has prefix to identify
#ip netns exec host1 /bin/bash --rcfile <(echo "PS1=\"namespace host1> \"")
ip net add host2
ip net exec host2 ifconfig lo up
#use below to enter namespace, it will has prefix to identify
#ip netns exec host2 /bin/bash --rcfile <(echo "PS2=\"namespace host1> \"")
echo "create host link"
ip link add host1_leth type veth peer name host1_peth
ip link set host1_leth netns host1
ip net exec host1 ifconfig host1_leth up
ip link set dev host1_peth up

ip link add host2_leth type veth peer name host2_peth
ip link set host2_leth netns host2
ip net exec host2 ifconfig host2_leth up
ip link set dev host2_peth up


ovs-vsctl add-port br1 host1_peth
ovs-vsctl add-port br$(($MAX_SWITCHES)) host2_peth

echo "done"
