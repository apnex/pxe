#!/bin/bash

INT="wlp0s20f3"
ADDRESS=$(ifconfig "${INT}" | grep inet[^6] | awk '{print $2}')
NETMASK=$(ifconfig "${INT}" | grep inet[^6] | awk '{print $4}')
GATEWAY=$(route -n | grep UG | awk '{print $2}')
DNS=$(nmcli -g ip4.dns device show "${INT}" | awk '{print $1}')

echo "ADDRESS	: [$ADDRESS]"
echo "NETMASK	: [$NETMASK]"
echo "GATEWAY	: [$GATEWAY]"
echo "DNS	: [$DNS]"

#cat > /etc/sysconfig/network-scripts/ifcfg-eth0 <<-EOM
cat > ./ifcfg-eth0 <<-EOM
	TYPE=Ethernet
	BOOTPROTO=none
	NAME=eth0
	DEVICE=eth0
	ONBOOT=yes
	IPADDR=${ADDRESS}
	PREFIX=24
	GATEWAY=${GATEWAY}
	DNS1=${DNS}
EOM

