url --url http://mirror.aarnet.edu.au/pub/centos/7/os/x86_64
eula --agreed
reboot

firstboot --enable
ignoredisk --only-use=sda
keyboard --vckeymap=us --xlayouts='us'
lang en_US.UTF-8

# Network information
#network --bootproto=static --device=eth0 --ip=10.30.0.50 --netmask=255.255.255.0 --gateway=10.30.0.254 --nameserver=8.8.8.8 --onboot=on --noipv6 --activate
#network --hostname=centos.lab
	
# Root password
rootpw --plaintext VMware1!
selinux --disabled
firewall --disabled
timezone Australia/Melbourne

# Partition clearing information & disable biosdevname! (package also removed)
bootloader --location=mbr --append="net.ifnames=0 biosdevname=0 ipv6.disable=1"
clearpart --all --initlabel
zerombr
autopart --type=lvm --fstype=ext4
# change to ext4 -- default is xfs gets corrupted on esx!

# minimal install
%packages --ignoremissing --excludedocs
@core --nodefaults
-aic94xx-firmware*
-alsa-*
-biosdevname
-btrfs-progs*
-dhcp*
-dracut-network
-iprutils
-ivtv*
-iwl*firmware
-libertas*
-kexec-tools
-plymouth*
-postfix
wget
net-tools
nano
open-vm-tools
%end

# generate network config
%pre --interpreter=/usr/bin/bash
INT="eth0"
ADDRESS=$(ifconfig "${INT}" | grep inet[^6] | awk '{print $2}')
NETMASK=$(ifconfig "${INT}" | grep inet[^6] | awk '{print $4}')
GATEWAY=$(route -n | grep UG | awk '{print $2}')
DNS=10.79.0.132

echo "ADDRESS	: [$ADDRESS]" >> /tmp/netlog
echo "NETMASK	: [$NETMASK]" >> /tmp/netlog
echo "GATEWAY	: [$GATEWAY]" >> /tmp/netlog
echo "DNS	: [$DNS]" >> /tmp/netlog

cat > /tmp/ifcfg-eth0 <<-EOF
	NAME=eth0
	DEVICE=eth0
	ONBOOT=yes
	TYPE=Ethernet
	BOOTPROTO=none
	IPV6INIT=no
	IPADDR=${ADDRESS}
	PREFIX=24
	GATEWAY=${GATEWAY}
	DNS1=${DNS}
EOF
%end

# install net script
%post
rm -f /etc/sysconfig/network-scripts/ifcfg-ens*
cp /tmp/ifcfg-eth0 /etc/sysconfig/network-scripts/ifcfg-eth0
cp /tmp/ifcfg-eth0 /etc/sysconfig/network-scripts/test-eth0
cp /tmp/netlog /etc/sysconfig/network-scripts/netlog

# need to add some code to modify sshd_config: UseDNS = no
# this is causing delays on SSH login prompts
sed -i 's/.*UseDNS.*/UseDNS no/g' /etc/ssh/sshd_config
service sshd restart
%end
