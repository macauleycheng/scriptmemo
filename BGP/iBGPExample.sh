#!/bin/bash

if [ "$1" = "" ]; then
docker run -d --privileged --name frr1 -v ${PWD}/daemons:/etc/frr/daemons frrouting/frr:latest
docker run -d --privileged --name frr2 -v ${PWD}/daemons:/etc/frr/daemons frrouting/frr:latest
docker run -d --privileged --name frr3 -v ${PWD}/daemons:/etc/frr/daemons frrouting/frr:latest

ip net add host1
ip net add host2
ip net add host3
ip net exec host1 ifconfig lo up
ip net exec host2 ifconfig lo up
ip net exec host3 ifconfig lo up
ip link add h1_leth type veth peer name h1_frr1
ip link add h2_leth type veth peer name h2_frr2
ip link add h3_leth type veth peer name h3_frr3
ip link add r_frr1 type veth peer name r_frr2_1
ip link add r_frr2_3 type veth peer name r_frr3
ip link set h1_leth netns host1
ip link set h2_leth netns host2
ip link set h3_leth netns host3
ip net exec host1 ip link set h1_leth up
ip net exec host2 ip link set h2_leth up
ip net exec host3 ip link set h3_leth up
ip net exec host1 ifconfig h1_leth 192.168.10.1/24
ip net exec host2 ifconfig h2_leth 192.168.20.1/24
ip net exec host3 ifconfig h3_leth 192.168.30.1/24

ip net exec host2 ip route add default via 192.168.20.2
ip net exec host1 ip route add 192.168.20.0/24 via 192.168.10.2
ip net exec host1 ip route add 192.168.50.0/24 via 192.168.10.2
ip net exec host1 ip route add 192.168.60.0/24 via 192.168.10.2
ip net exec host1 ip route add 192.168.30.0/24 via 192.168.10.2
ip net exec host3 ip route add 192.168.20.0/24 via 192.168.30.2
ip net exec host3 ip route add 192.168.50.0/24 via 192.168.30.2
ip net exec host3 ip route add 192.168.60.0/24 via 192.168.30.2
ip net exec host3 ip route add 192.168.10.0/24 via 192.168.30.2

docker inspect frr1 | grep Pid
docker inspect frr2 | grep Pid
docker inspect frr3 | grep Pid

ip link set h1_frr1 netns 594091
ip link set r_frr1 netns 594091
ip link set h2_frr2 netns 594216
ip link set r_frr2_1 netns 594216
ip link set r_frr2_3 netns 594216
ip link set h3_frr3 netns 594345
ip link set r_frr3 netns 594345

#frr1
docker exec -it frr1 bash
ip link set h1_frr1 up
ip link set r_frr1 up
vtysh
configure
interface h1_frr1
ip address 192.168.10.2/24
exit
interface r_frr1
ip address 192.168.50.1/24
end
configure
ip route 192.168.30.0/24 192.168.50.2
ip route 192.168.60.0/24 192.168.50.2 
router bgp 1000
bgp router-id 192.168.50.1
neighbor 192.168.50.2 remote-as 1000
address-family ipv4 unicast
network 192.168.10.0/24
end

#frr2
docker exec -it frr2 bash
ip link set h2_frr2 up
ip link set r_frr2_1 up
ip link set r_frr2_3 up
vtysh
configure
interface h2_frr2
ip address 192.168.20.2/24
exit
interface r_frr2_1
ip address 192.168.50.2/24
exit
interface r_frr2_3 
ip address 192.168.60.2/24
end
configure
router bgp 1000
bgp router-id 192.168.50.2
neighbor 192.168.50.1 remote-as 1000
neighbor 192.168.60.1 remote-as 1000
address-family ipv4 unicast
network 192.168.20.0/24
end

#frr3
docker exec -it frr3 bash
ip link set h3_frr3 up
ip link set r_frr3 up
vtysh
configure
interface h3_frr3 
ip address 192.168.30.2/24
exit
interface r_frr3 
ip address 192.168.60.1/24
end
configure
ip route 192.168.10.0/24 192.168.60.2
ip route 192.168.50.0/24 192.168.60.2
router bgp 1000
bgp router-id 192.168.60.1
neighbor 192.168.60.2 remote-as 1000
address-family ipv4 unicast
network 192.168.30.0/24
end

else
ip net delete host1
ip net delete host2
ip net delete host3
docker stop frr1
docker stop frr2
docker stop frr3
docker rm frr1
docker rm frr2
docker rm frr3
fi
