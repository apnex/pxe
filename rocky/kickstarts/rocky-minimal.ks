url --url http://download.rockylinux.org/pub/rocky/9.5/BaseOS/x86_64/os/
firstboot --enable
eula --agreed

#text
#bootloader --disable
# Partition clearing information & disable biosdevname! (package also removed)
# change to ext4 -- default is xfs gets corrupted on esx!
network --bootproto=dhcp --device=link --noipv6 --onboot=on --activate
rootpw --plaintext VMware1!
selinux --disabled
firewall --disabled
reboot

keyboard us
lang en_US.UTF-8
timezone --utc --nontp Etc/UTC

# Disk setup
ignoredisk --only-use=sda
bootloader --location=mbr --append="net.ifnames=0 biosdevname=0 ipv6.disable=1"
clearpart --all --initlabel
zerombr
autopart --type=lvm --fstype=ext4
#autopart --noboot --nohome --noswap --nolvm --fstype=ext4

%addon com_redhat_kdump --disable
%end

%packages --excludedocs --inst-langs=en --nocore --exclude-weakdeps
bash
coreutils-single
glibc-minimal-langpack
microdnf
rocky-release
util-linux

#-gettext*
#-iputils
-brotli
-dosfstools
-e2fsprogs
-firewalld
-fuse-libs
-gnupg2-smime
-grub\*
-hostname
-iptables
-kernel
-kexec-tools
-less
-libss
-os-prober*
-pinentry
-qemu-guest-agent
-rootfiles
-shared-mime-info
-tar
-trousers
-vim-minimal
-xfsprogs
-xkeyboard-config
-yum
%end

%post --erroronfail --log=/root/anaconda-post.log
# container customizations inside the chroot

rpm --rebuilddb
/bin/date +%Y-%m-%d_%H:%M:%S > /etc/BUILDTIME
echo 'container' > /etc/dnf/vars/infra

LANG="en_US"
echo '%_install_langs en_US.UTF-8' > /etc/rpm/macros.image-language-conf
echo 'LANG="C.UTF-8"' >  /etc/locale.conf
rm -f /var/lib/dnf/history.* 
rm -fr "/var/log/*" "/tmp/*" "/tmp/.*"
for dir in $(ls -d "/usr/share/{locale,i18n}/*" | grep -v 'en_US\|all_languages\|locale\.alias'); do rm -fr $dir; done

# systemd fixes
umount /run
systemd-tmpfiles --create --boot

# mask mounts and login bits
systemctl mask \
    console-getty.service \
    dev-hugepages.mount \
    getty.target \
    sys-fs-fuse-connections.mount \
    systemd-logind.service \
    systemd-remount-fs.service

# Cleanup the image
rm -f /etc/udev/hwdb.bin
rm -rf /usr/lib/udev/hwdb.d/ \
       /boot /var/lib/dnf/history.* \
      "/tmp/*" "/tmp/.*" || true

%end
