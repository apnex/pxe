## PXE
### Tips and Tricks using iPXE
iPXE is a modern lightweight replacement for the legacy BIOS PXE agent that comes pre-loaded with most systems.  
It is useful for bootstrapping automated OS builds via the network, with a highly flexible scripting syntax.  
iPXE also supports a number of external sources beyond standard TFTP such as:  
- HTTP
- iSCSI
- FC

This provides a more modern method of retrieving necessary configurations scripts, kickstart files and boot images.  
iPXE can be found here:  
https://ipxe.org

### Deployment Methods
iPXE can be setup in a number of ways depending on your situation  
Build options for iPXE are listed here:  
https://ipxe.org/download

#### Chain-loading
This involves leveraging the legacy BIOS PXE TFTP method to load iPXE code, and then call iPXE scripts.  
This uses the existing legacy BIOS PXE code to replace itself, and then proceed with iPXE.  
iPXE scripts can then load other iPXE scripts (via any supported network method - i.e HTTP).  
More info:  
https://ipxe.org/howto/chainloading

#### Embedded ROM
This involves crafting a pre-baked iPXE ROM image, and "flashing" it into the chipset of the machine NIC.
This replaces the existing legacy PXE code.

#### Embedded ISO
This involves crafting a pre-baked bootable ISO CDROM image, and mounting this to a machine to boot from.
This replaces the existing legacy PXE code.

### Examples
#### Unattended CentOS Installation using ISO
Here is an example of how to leverage iPXE to kickoff an unattended Centos installation on a new VM.  
This uses the "embedded iso" method described above.

#### Usage
To use this example, simply download the pre-made ISO from here:  
http://pxe.apnex.io/centos.iso

It is a tiny 1MB ISO - as it contains only iPXE code.  
All remaining OS files will be bootstrapped over the Internet via HTTP.  
Just mount this ISO to a CDROM of a VM and power on.  

**Warning**: Ensure you have created your VM with a following boot order:  
1) HDD  
2) CDROM  
This is to ensure that after installation, the VM will boot normally.  
If CDROM is before HDD, the VM will be in an infinite loop restarting and rebuilding itself!  

#### Backstory Stuff
These are the steps I performed to create the above ISO and PXE boot sequence.

**Create an initial iPXE script called `boot.ipxe` to kickoff the launch**
```
#!ipxe
dhcp
chain http://pxe.apnex.io/centos.ipxe
```
This will be "baked" into the ISO image to load another iPXE script over the Internet.  
This file is referenced using the `make bin/ipxe.iso EMBED=boot.ipxe` command.  

**Create the upstream iPXE script `centos.ipxe` that will be called from the mounted ISO**
```
#!ipxe
set boot http://pxe.apnex.io
set mirror http://mirror.optus.net/centos/7
kernel ${mirror}/os/x86_64/images/pxeboot/vmlinuz initrd=initrd.img ks=${boot}/centos.ks ip=dhcp
initrd ${mirror}/os/x86_64/images/pxeboot/initrd.img
boot
```
This will then be hosted online at `http://pxe.apnex.io/centos.ipxe` ready to be called.  
This script is a minimal config for a CentOS net-install and I have hard-coded the mirror repo.  
It is also calling a kickstart file `centos.ks` for CentOS specific install options.  

**Create a kickstart file `centos.ks`**
```
install
url --url  http://mirror.optus.net/centos/7/os/x86_64
eula --agreed
reboot

firstboot --enable
ignoredisk --only-use=sda
keyboard --vckeymap=us --xlayouts='us'
lang en_US.UTF-8

# Network information
network --bootproto=dhcp --device=eth0 --onboot=on --noipv6 --activate
network --hostname=centos.lab
services --enabled=network
	
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
# change to ext4 -- default is xfs and constantly gets corrupt on esx!

# minimal install
%packages --nobase --ignoremissing --excludedocs
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
-NetworkManager*
-plymouth*
-postfix
wget
net-tools
nano
open-vm-tools
%end

%post
rm -f /etc/sysconfig/network-scripts/ifcfg-ens*
cat > /etc/sysconfig/network-scripts/ifcfg-eth0 <<EOM
TYPE=Ethernet
BOOTPROTO=dhcp
NAME=eth0
DEVICE=eth0
ONBOOT=yes
EOM

# need to add some code to modify sshd_config: UseDNS = no
# this is causing delays on SSH login prompts
sed -i 's/.*UseDNS.*/UseDNS no/g' /etc/ssh/sshd_config
service sshd restart

%end
```
This is a standard kickstart syntax, and has many different options that can be tweaked depending on environment.  
I have crafted the `%packages` section for an absolute minimal install that can be added to after the fact.  
I have also disable IPv6 and renamed the eth port to `eth0`.  
After install, the login credentials will be `root` / `VMware1!`  

### That's it! - go forth and create / customise further as you see fit
