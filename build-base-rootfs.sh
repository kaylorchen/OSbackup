#!/bin/bash
#Check if this is run with sudo, and exit otherwise
if [ "$EUID" -ne 0 ]
  then echo "Please run as root"
  exit
fi
ROOTFS=${1}
echo rootfs directory is \"$ROOTFS\".
ls ubuntu-base-20.04.5-base-*.tar.gz > /dev/null 2>&1
if [ $? != "0" ]; then
    echo "Download ubuntu base rootfs"
    wget http://cdimage.ubuntu.com/ubuntu-base/releases/20.04.5/release/ubuntu-base-20.04.5-base-amd64.tar.gz
fi
echo "Uncompress rootfs"
mkdir $ROOTFS
cd $ROOTFS
tar -xvpzf ../ubuntu-base-20.04.5-base-amd64.tar.gz
cd ..
cp ./sources.list.china $ROOTFS/etc/apt/sources.list
echo "Copy the current host's resolv.conf to rootfs"
cp /etc/resolv.conf $ROOTFS/etc/resolv.conf
echo "127.0.0.1 localhost" > $ROOTFS/etc/hosts
echo "127.0.0.1 sudo" > $ROOTFS/etc/hosts
echo "Hunter" > $ROOTFS/etc/hostname
echo "Config rootfs"
echo 'apt update
apt upgrade -y
'|bash ch-mount.sh -m $ROOTFS

echo 'apt install tree resolvconf curl ssh gnupg gnupg1 gnupg2 net-tools wireless-tools ifupdown ethtool iputils-ping bash-completion pciutils usbutils dbus dhcpcd-dbus psmisc alsa-base vim language-pack-en-base sudo  rsyslog  htop lsb-release grub-efi iw wpasupplicant hostapd udev rsync -y
'|bash ch-mount.sh -m $ROOTFS

echo configure user files.
echo '
sed -i -e "s/#PermitRootLogin prohibit-password/PermitRootLogin yes/g" /etc/ssh/sshd_config
echo "/dev/root            /                    auto       rw                    1  0" >> /etc/fstab
echo "proc                 /proc                proc       defaults              0  0" >> /etc/fstab
echo "devpts               /dev/pts             devpts     mode=0620,gid=5       0  0" >> /etc/fstab
echo "tmpfs                /run                 tmpfs      mode=0755,nodev,nosuid,strictatime 0  0" >> /etc/fstab
sed -i -e "s/TimeoutStartSec=5min/TimeoutStartSec=1sec/g" /lib/systemd/system/networking.service
sed -i -e "s/WatchdogSec=3min/WatchdogSec=3sec/g" /lib/systemd/system/systemd-networkd.service
systemctl mask wpa_supplicant.service
# systemctl mask getty@tty1.service
systemctl disable dhcpcd.service
echo "allow-hotplug eth0" >> /etc/network/interfaces.d/eth0
echo "iface eth0 inet dhcp"  >> /etc/network/interfaces.d/eth0
echo "allow-hotplug eth1" >> /etc/network/interfaces.d/eth1
echo "iface eth1 inet dhcp"  >> /etc/network/interfaces.d/eth1
echo "nameserver 114.114.114.114" >> /etc/resolvconf/resolv.conf.d/tail
echo set ts=4 >>/etc/vim/vimrc
echo set expandtab >>/etc/vim/vimrc
echo set nu >>/etc/vim/vimrc
echo colorscheme desert >> /etc/vim/vimrc
echo set relativenumber >> /etc/vim/vimrc
echo set paste >> /etc/vim/vimrc
echo set encoding=utf8 >> /etc/vim/vimrc
mv /etc/apt/sources.list /etc/apt/sources.list.old
touch /etc/apt/sources.list
apt update
apt clean
echo -e "kaylor\nkaylor\n"|passwd root
exit
'|bash ch-mount.sh -m $ROOTFS


