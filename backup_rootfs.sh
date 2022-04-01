#!/bin/bash
#Check if this is run with sudo, and exit otherwise
if [ "$EUID" -ne 0 ]
  then echo "Please run as root"
  exit
fi
time=$(date +%Y-%m+%d)
user=${SUDO_USER}

rootfs_tar=$(pwd)/ubuntu_rootfs@${time}.tar.gz
home_tar=$(pwd)/ubuntu_home@${time}.tar.gz
cd /
echo "tar a rootfs package:${rootfs_tar}"
sudo tar -cvpzf ${rootfs_tar} \
--exclude=/boot/efi \
--exclude=/proc \
--exclude=/tmp \
--exclude=/home \
--exclude=/lost+found \
--exclude=/media \
--exclude=/mnt \
--exclude=/sys \
--exclude=/dev \
--exclude=/var/log \
--exclude=/var/cache/apt/archives \
--exclude=/run /

echo "tar a home package: ${home_tar}"
sudo tar -cvpzf ${home_tar} --exclude=${home_tar} /home

echo "------------------------"

