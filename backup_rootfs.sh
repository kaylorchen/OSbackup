#!/bin/bash
#Check if this is run with sudo, and exit otherwise
if [ "$EUID" -ne 0 ]
  then echo "Please run as root"
  exit
fi
time=$(date +%Y-%m+%d)
user=${SUDO_USER}

rootfs_tar=$(pwd)/ubuntu_rootfs@${time}.tar.gz
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

echo "------------------------"

