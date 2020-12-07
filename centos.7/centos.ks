url --url http://mirror.aarnet.edu.au/pub/centos/7/os/x86_64
eula --agreed
reboot

# Initial
firstboot --enable
ignoredisk --only-use=sda
keyboard --vckeymap=us --xlayouts='us'
lang en_US.UTF-8

# Network info
#network --device=eth0 --noipv6 --hostname=centos.lab

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

# install net script
%post
# need to add some code to modify sshd_config: UseDNS = no
# this is causing delays on SSH login prompts
sed -i 's/.*UseDNS.*/UseDNS no/g' /etc/ssh/sshd_config
service sshd restart
%end
