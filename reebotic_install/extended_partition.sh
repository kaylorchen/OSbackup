#!/bin/bash

#Check if this is run with sudo, and exit otherwise
if [ "$EUID" -ne 0 ]; then
  echo "Please run as root"
  exit
fi
dev=${1}
partition=${2}

df | grep ${dev} >/dev/null 2>&1
if [ $? = "0" ]; then
  mount_list=$(df | grep ${dev} | awk -F ' ' '{ print $1}')
  for line in $mount_list; do
    echo "umounting $line"
    umount $line
  done
fi

parted -s ${dev} p
parted -s ${dev} resizepart ${partition} 100%
parted -s ${dev} p

echo "Associating loopback device to image"
sudo losetup /dev/loop100 --partscan --show ${dev}

echo "e2fsck is running"
e2fsck -y -f /dev/loop100p${partition}

echo "resize2fs is running"
resize2fs -f /dev/loop100p${partition}

echo "Umounting loopback device"
sudo losetup -d /dev/loop100
