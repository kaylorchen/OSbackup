#!/bin/bash
#Check if this is run with sudo, and exit otherwise
if [ "$EUID" -ne 0 ]
  then echo "Please run as root"
  exit
fi
time=$(date +%Y-%m+%d)
user=$(whoami)

rootfs_tar=/home/${user}/ubuntu_rootfs@${time}.tar.gz
home_tar=/home/${user}/ubuntu_home@${time}.tar.gz
cd /
echo "tar a rootfs package:${rootfs_tar}"
sudo tar -cvpzf ${rootfs_tar} --exclude=/proc --exclude=/tmp --exclude=/home --exclude=/lost+found --exclude=/media --exclude=/mnt --exclude=/run /

echo "tar a home package: ${home_tar}"
sudo tar -cvpzf ${home_tar} --exclude=${home_tar} /home

