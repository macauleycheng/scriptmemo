#!/bin/bash


MAX_SWITCHES=3
CTRL_IP=192.168.40.37
j=0

for i in $(seq 1 $MAX_SWITCHES);
  do
        ovs-vsctl add-br br$i
        ovs-vsctl set bridge br$i protocols=OpenFlow13
        datapath=$(printf "00000000000000%02x" $i)
        echo $datapath br$i
        ovs-vsctl set bridge br$i other-config:datapath-id=$datapath
        ovs-vsctl set-controller br$i tcp:$CTRL_IP:6653
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
MAX_HOSTS_A_SWITCH=500
j=168
k=1
for i in $(seq 1 $MAX_HOSTS_A_SWITCH);
do
ip net add host$i
ip net add host$(($MAX_HOSTS_A_SWITCH + $i))

echo "create host link"
ip link add host"$i"_leth type veth peer name host"$i"_peth
ip link set host"$i"_leth netns host$i
ip net exec host$i ifconfig host"$i"_leth up
ip net exec host$i ifconfig host"$i"_leth 192.$j.$k.1/24
ip link set dev host"$i"_peth up

ip link add host"$(($MAX_HOSTS_A_SWITCH + $i))"_leth type veth peer name host"$(($MAX_HOSTS_A_SWITCH + $i))"_peth
ip link set host"$(($MAX_HOSTS_A_SWITCH + $i))"_leth netns host$(($MAX_HOSTS_A_SWITCH + $i))
ip net exec host"$(($MAX_HOSTS_A_SWITCH + $i))" ifconfig host"$(($MAX_HOSTS_A_SWITCH + $i))"_leth up
ip net exec host"$(($MAX_HOSTS_A_SWITCH + $i))" ifconfig host"$(($MAX_HOSTS_A_SWITCH + $i))"_leth 192.$j.$k.2/24
ip link set dev host"$(($MAX_HOSTS_A_SWITCH + $i))"_peth up


ovs-vsctl add-port br1 host"$i"_peth
ovs-vsctl add-port br$(($MAX_SWITCHES)) host"$(($MAX_HOSTS_A_SWITCH + $i))"_peth

k=$(($k +1))
if [ $(($i % 255)) -eq 0 ];
then
   j=$(($j + 1))
   k=1
fi
echo "k=$k, j=$j"

done
echo "done"
