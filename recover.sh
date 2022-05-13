#!/bin/bash
if [ "$EUID" -ne 0 ]
  then echo "Please run as root"
  exit
fi
echo "your rootfs is ${1}"
rootfs_tar=${1}

echo "mount "
sudo mkdir -p /mnt/rootfs
sudo mount ${1} /mnt/rootfs

sudo tar -xvpzf ${rootfs_tar} -C /mnt/rootfs
cd /mnt/rootfs
sudo mkdir boot/efi 
sudo mkdir proc 
sudo mkdir tmp 
sudo mkdir home 
sudo mkdir lost+found 
sudo mkdir media 
sudo mkdir mnt 
sudo mkdir sys 
sudo mkdir dev 
sudo mkdir var/log 
sudo mkdir var/cache/apt/archives 
sudo mkdir run 
cd 
sudo mount -o bind /dev /mnt/rootfs/dev
sudo mount -o bind /proc /mnt/rootfs/proc
sudo mount -o bind /sys /mnt/rootfs/sys
sudo chroot /mnt/rootfs
update-grub
sync
exit
sudo umount /mnt/rootfs/dev
sudo umount /mnt/rootfs/sys
sudo umount /mnt/rootfs/proc
sync
sudo umount /mnt/rootfs
