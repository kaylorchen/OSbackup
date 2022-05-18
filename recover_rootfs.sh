#!/bin/bash
if [ "$EUID" -ne 0 ]
  then echo "Please run as root"
  exit
fi
rootfs_tar=${1}
dev=${DEV}
echo "device is ${dev}, rootfs tar is ${rootfs_tar}"
if [ ! -n "$dev" ] ; then
    echo "error, DEV is empty"
    exit
fi
ls ${dev} > /dev/null 2>&1
if [ $? != "0" ]; then
    echo ls ${dev}: No such file or directory
    exit
fi

echo "Associating loopback device to image"
sudo losetup /dev/loop100 --partscan --show ${dev}

echo "Mounting rootfs device"
sudo mkdir -p /mnt/rootfs
sudo mount /dev/loop100p2 /mnt/rootfs

echo "Uncompressing rootfs file"
sudo tar -xvpzf ${rootfs_tar} -C /mnt/rootfs
sudo mkdir -p /mnt/rootfs/boot/efi
sudo mkdir -p /mnt/rootfs/proc
sudo mkdir -p /mnt/rootfs/tmp
sudo mkdir -p /mnt/rootfs/home
sudo mkdir -p /mnt/rootfs/lost+found
sudo mkdir -p /mnt/rootfs/media
sudo mkdir -p /mnt/rootfs/mnt
sudo mkdir -p /mnt/rootfs/sys
sudo mkdir -p /mnt/rootfs/dev
sudo mkdir -p /mnt/rootfs/var/log
sudo mkdir -p /mnt/rootfs/var/cache/apt/archives
sudo mkdir -p /mnt/rootfs/run

echo "Umounting rootfs device"
sudo sync
sleep 3
sudo umount /mnt/rootfs
sudo losetup -d /dev/loop100

