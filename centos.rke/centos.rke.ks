url --url http://mirror.aarnet.edu.au/pub/centos/7/os/x86_64
eula --agreed
reboot

firstboot --enable
ignoredisk --only-use=sda
keyboard --vckeymap=us --xlayouts='us'
lang en_US.UTF-8

# Network information
#network --bootproto=dhcp --device=eth0 --onboot=on --noipv6 --hostname=centos.lab
	
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

%post --interpreter /bin/bash

# need to add some code to modify sshd_config: UseDNS = no
# this is causing delays on SSH login prompts
sed -i 's/.*UseDNS.*/UseDNS no/g' /etc/ssh/sshd_config
service sshd restart

## setup runonce service
cat << EOF > /etc/systemd/system/runonce.service
[Unit]
Description=Run once
Requires=network-online.target
After=network-online.target

[Service]
ExecStart=/root/runonce.sh

[Install]
WantedBy=multi-user.target
EOF

chmod 664 /etc/systemd/system/runonce.service
systemctl enable runonce

## setup runonce script
touch /tmp/runonce
curl -Lo /root/runonce.sh https://labops.sh/rke/runonce.sh
chmod 755 /root/runonce.sh

%end
