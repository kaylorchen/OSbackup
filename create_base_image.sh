#!/bin/bash
#Check if this is run with sudo, and exit otherwise
if [ "$EUID" -ne 0 ]
  then echo "Please run as root"
  exit
fi
sudo bash update-rootfs.sh rootfs_base
sudo bash copy_kernel_and_modules.sh

rootfs_size=$(du --max-depth=0 rootfs_base | awk -F ' ' '{print $1}')
kernel_and_modules_size=$(du --max-depth=0 linux | awk -F ' ' '{print $1}')
echo "rootfs size is ${rootfs_size} kBytes, kernel_and_modules_size is ${kernel_and_modules_size} kBytes"
total_size=$(expr $rootfs_size \+ $kernel_and_modules_size)
echo "total size is $total_size kBytes"
image_size=$(expr $total_size \/ 1024 \+ 400)
echo "image size is $image_size MB"
echo "${image_size}
"|sudo bash create_blank_image.sh

echo "Associating loopback device to image"
sudo losetup /dev/loop100 --partscan --show disk.img

echo "Create a rootfs mount point"
sudo mkdir rootfs

echo "Mounting disk image rootfs partition"
sudo mount /dev/loop100p2 rootfs

echo "Create a efi mount point"
sudo mkdir -p rootfs/boot/efi

echo "Mounting disk image efi partition"
sudo mount /dev/loop100p1 rootfs/boot/efi

echo "Sync files"
sudo rsync -az rootfs_base/ rootfs/
sudo rsync -az linux/kernel/ rootfs/boot/
sudo rsync -az linux/lib/modules rootfs/lib/
sudo ls -l rootfs
sudo ls -l rootfs/boot/
sudo ls -l rootfs/lib/modules/
sudo sync
echo "GRUB_DISABLE_OS_PROBER=true" >> rootfs/etc/default/grub
sed -i -e "s/GRUB_TIMEOUT=0/GRUB_TIMEOUT=10/g" rootfs/etc/default/grub
sed -i -e "s/quiet//g" rootfs/etc/default/grub
sed -i -e "s/splash//g" rootfs/etc/default/grub
sed -i -e "s/hidden/menu/g" rootfs/etc/default/grub
sed -i -e "s/GRUB_CMDLINE_LINUX=\"\"/GRUB_CMDLINE_LINUX=\"net.ifnames=0 biosdevname=0\"/g" rootfs/etc/default/grub
cat rootfs/etc/default/grub

echo "Update grub"
echo "update-grub
sync
exit
"| bash ch-mount.sh -m rootfs

echo "Umounting loopback device"
sudo umount rootfs/boot/efi
sudo umount rootfs
sudo losetup -d /dev/loop100
sudo rm rootfs -rf