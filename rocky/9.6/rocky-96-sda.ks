url --url http://download.rockylinux.org/pub/rocky/9.6/BaseOS/x86_64/os/
firstboot --enable
eula --agreed
reboot

# Partition clearing information & disable biosdevname! (package also removed)
# change to ext4 -- default is xfs gets corrupted on esx!
network --bootproto=dhcp --device=link --noipv6 --onboot=on --activate
rootpw --plaintext google1! --allow-ssh
selinux --disabled
firewall --disabled
keyboard us
lang en_US.UTF-8
timezone Australia/Sydney --utc

# Disk setup
ignoredisk --only-use=sda
bootloader --location=mbr --append="net.ifnames=0 biosdevname=0 ipv6.disable=1"
clearpart --all --initlabel
zerombr

# Partition clearing information
#clearpart --none --initlabel
part swap --fstype="swap" --ondisk=sda --size=8049
part /boot --fstype="xfs" --ondisk=sda --size=1024
part /boot/efi --fstype="efi" --ondisk=sda --size=600 --fsoptions="umask=0077,shortname=winnt"
part / --fstype="xfs" --ondisk=sda --size=1 --grow

%addon com_redhat_kdump --disable
%end

# packages
%packages --excludedocs --inst-langs=en --exclude-weakdeps
@core
@standard
-iwl*firmware
-libertas*firmware
-biosdevname

## additional packages
qemu-guest-agent
nfs-utils
traceroute
bind-utils
%end

%post --interpreter /bin/bash
# setup systemd to boot to the right runlevel
rm -f /etc/systemd/system/default.target
ln -s /lib/systemd/system/multi-user.target /etc/systemd/system/default.target
echo .

# we don't need this in virt
#dnf -C -y remove linux-firmware

# this should *really* be an empty file - gotta make anaconda happy
truncate -s 0 /etc/resolv.conf

# For cloud images, 'eth0' _is_ the predictable device name, since
# we don't want to be tied to specific virtual (!) hardware
rm -f /etc/udev/rules.d/70*
ln -s /dev/null /etc/udev/rules.d/80-net-name-slot.rules

# Update sshd_config to permit root login
sed -i '/UseDNS/d' /etc/ssh/sshd_config
echo "UseDNS no" >>/etc/ssh/sshd_config
sed -i '/PermitRootLogin/d' /etc/ssh/sshd_config
echo "PermitRootLogin yes" >>/etc/ssh/sshd_config
service sshd restart

# clear seed / machine-id
#rm -f /var/lib/systemd/random-seed
#cat /dev/null > /etc/machine-id
#true

%end
