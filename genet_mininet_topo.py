#!/usr/bin/python

import re
from mininet.net import Mininet
from mininet.node import Controller
from mininet.cli import CLI
from mininet.link import Intf
from mininet.log import setLogLevel, info, error
from mininet.util import quietRun
from mininet.node import RemoteController, OVSSwitch
#from mininet.node import OVSController
#import pdb


MAX_SWITCHES=3
MAX_HOSTS_EACH_SWITCH=1
INTF_TO_SWITCH='enp2s0'

def checkIntf( intf ):
    "Make sure intf exists and is not configured."
    if ( ' %s:' % intf ) not in quietRun( 'ip link show' ):
        error( 'Error:', intf, 'does not exist!\n' )
        exit( 1 )
    ips = re.findall( r'\d+\.\d+\.\d+\.\d+', quietRun( 'ifconfig ' + intf ) )
    if ips:
        error( 'Error:', intf, 'has an IP address and is probably in use!\n' )
        exit( 1 )


def myNetwork():

    net = Mininet( topo=None, build=False)

    info( '*** Adding controller\n' )
    net.addController(name='mars', controller=RemoteController, ip = '192.168.137.10', protocol='tcp', port=6653)

    switch_list={}
    info ( '***  Add switches\n')
    for i in xrange(1, MAX_SWITCHES+1):
        info( '*** Add switches-', i, '\n')
        switch_name = 's'+ str(i)
        switch_list[i] = net.addSwitch(switch_name)


    host_list = {}
    info( '*** Add hosts\n')
    for i in xrange(1, MAX_HOSTS_EACH_SWITCH * MAX_SWITCHES + 1):
        info('****  Add host -', i, '\n')
        host_list[i] = net.addHost('h'+str(i))

#    pdb.set_trace()

    index=1
    for k,s in switch_list.items():        
        for i in xrange(0, MAX_HOSTS_EACH_SWITCH):
            info( '*** Add links between ',host_list[index],' and switch', s,' \n')        
            net.addLink(host_list[index], s)
            index=index+1



    info('add links between switch\n')
    for i in xrange(1, len(switch_list)):
       net.addLink(switch_list[i], switch_list[i+1])


    """
    info( '*** Checking the interface ', INTF_TO_SWITCH , '\n' )
    checkIntf( INTF_TO_SWITCH )

    switch = net.switches[ 0 ]
    info( '*** Adding', INTF_TO_SWITCH, 'to switch', switch.name, '\n' )
    brintf = Intf( INTF_TO_SWITCH, node=switch )
    """

    info( '*** Starting network\n')
    net.start()

    CLI(net)
    net.stop()

if __name__ == '__main__':
    setLogLevel( 'info' )
    myNetwork()
