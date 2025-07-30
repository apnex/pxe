# show script's output
exec > >(tee -a /dev/tty0) 2>&1

GATEWAY=$(ip route show | awk '/^default/ {print $3}')
INTERFACE=$(ip route show | awk '/^default/ {print $5}')
PREFIX=$(ip addr show ${INTERFACE} | awk '/inet / {print $2}')
ADDRESS=$(printf ${PREFIX} | head -n 1 | sed 's:/.*::')
NETMASK=$(ipcalc -m ${PREFIX} | sed 's/.*=//')
NAMESERVER=$(cat /etc/resolv.conf | awk '/^nameserver/ {print $2}' | head -n 1)

# extract hostname from kernel params
HOSTNAME=$(cat /proc/cmdline | awk -F= -v RS=" " '/^hostname=/{print $2}')
if [ -z ${HOSTNAME} ]; then
	HOSTNAME="alpine" # default value
fi

# extract script from kernel params
BOOTSCRIPT=$(cat /proc/cmdline | awk -F= -v RS=" " '/^bootscript=/{print $2}')

echo "-- NETWORK PARAMS --"
echo ${GATEWAY}
echo ${INTERFACE}
echo ${PREFIX}
echo ${ADDRESS}
echo ${NETMASK}
echo ${NAMESERVER}
echo ${HOSTNAME}
echo ${BOOTSCRIPT}
echo "-- NETWORK PARAMS --"

# setup interfaces
setup-interfaces -i <<EOF
auto lo
iface lo inet loopback

auto ${INTERFACE}
iface ${INTERFACE} inet static
        address ${ADDRESS}
        netmask ${NETMASK}
        gateway ${GATEWAY}
EOF
rc-update add networking boot

# disable ipv6
cat <<-EOF >>/etc/sysctl.conf
	net.ipv4.ip_forward=1
	net.ipv6.conf.all.disable_ipv6=1
	net.ipv6.conf.default.disable_ipv6=1
	net.ipv6.conf.lo.disable_ipv6=1
EOF
sysctl -p

# do the system installation
echo root:google1! | chpasswd
printf 'openssh\nyes' | setup-sshd
setup-keymap us us
setup-timezone -i UTC
setup-hostname ${HOSTNAME}
setup-ntp chrony || true
true >/etc/apk/repositories
setup-apkrepos -1 -c
printf 'y' | setup-disk -m sys /dev/sda

# setup runonce here
BOOTSCRIPT="http://pxe.apnex.io/alpine/alpine-runonce.start"
if [ -n "${BOOTSCRIPT}" ]; then # default value
	mount /dev/sda3 /mnt
	wget -O /mnt/etc/init.d/runonce.start "${BOOTSCRIPT}"
	chmod +x /mnt/etc/init.d/runonce.start
	ln -s /etc/init.d/runonce.start /mnt/etc/runlevels/default/runonce.start
fi

reboot
