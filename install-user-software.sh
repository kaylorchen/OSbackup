#!/bin/bash
#Check if this is run with sudo, and exit otherwise
if [ "$EUID" -ne 0 ]
  then echo "Please run as root"
  exit
fi
ROOTFS=${1}
cp ./sources.list.china $ROOTFS/etc/apt/sources.list
echo "Install user software..."
software=$(sed ':label;N;s/\n/ /;b label' software_list.txt | sed 's/[[:space:]][[:space:]]*/ /g' )
echo "software list: $software"
echo "apt update
apt install ${software} -y
mv /etc/apt/sources.list /etc/apt/sources.list.old
touch /etc/apt/sources.list
apt update
apt clean
exit
"|bash ch-mount.sh -m $ROOTFS

