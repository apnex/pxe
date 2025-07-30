#!/bin/sh

GATEWAY=$(ip route show | awk '/^default/ {print $3}')
INTERFACE=$(ip route show | awk '/^default/ {print $5}')
PREFIX=$(ip addr show ${INTERFACE} | awk '/inet / {print $2}')
ADDRESS=$(printf ${PREFIX} | head -n 1 | sed 's:/.*::')
NETMASK=$(ipcalc -m ${PREFIX} | sed 's/.*=//')
NAMESERVER=$(cat /etc/resolv.conf | awk '/^nameserver/ {print $2}' | head -n 1)

echo ${GATEWAY}
echo ${INTERFACE}
echo ${PREFIX}
echo ${ADDRESS}
echo ${NETMASK}
echo ${NAMESERVER}
