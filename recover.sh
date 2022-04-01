#!/bin/bash
if [ "$EUID" -ne 0 ]
  then echo "Please run as root"
  exit
fi
echo "your rootfs is ${1}"
rootfs_tar=${1}

echo "mount "
mkdir mnt
sudo mount /dev/sda2 mnt

sudo tar -xvpzf ${rootfs_tar} -C mnt/
sudo umount mnt
