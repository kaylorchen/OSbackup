#!/bin/bash
if [ "$EUID" -ne 0 ]
  then echo "Please run as root"
  exit
fi

if [ ! -n "${DEV}" ] ; then
    echo "error, ${DEV} is empty"
    exit
fi

device=${DEV}

ls ${device} > /dev/null 2>&1
if [ $? != "0" ]; then
    echo ls ${device}: No such file or directory
    exit
fi

echo "Associating loopback device to image"
sudo losetup /dev/loop100 --partscan --show ${device}
dev=/dev/loop100

efi_uuid=$(sudo blkid | grep  ${dev}p1  | awk -F '"' '{print $2}')
rootfs_uuid=$(sudo blkid | grep  ${dev}p2 | awk -F '"' '{print $2}')
home_uuid=$(sudo blkid | grep  ${dev}p3  | awk -F '"' '{print $2}')
rootfs_dev=$(sudo blkid | grep  ${dev}p2 | awk -F ':' '{print $1}')
efi_dev=$(sudo blkid | grep  ${dev}p1  | awk -F ':' '{print $1}')
echo "rootfs_dev is ${rootfs_dev}, efi_dev is ${efi_dev}"

sudo cp fstab.original fstab
sudo sed -i -e 's/rootfs_uuid/'${rootfs_uuid}'/g' fstab
sudo sed -i -e 's/efi_uuid/'${efi_uuid}'/g' fstab
sudo sed -i -e 's/home_uuid/'${home_uuid}'/g' fstab

echo "Create a rootfs mount point"
sudo mkdir rootfs

echo "Mounting disk image rootfs partition"
sudo mount -o rw ${rootfs_dev} rootfs
sleep 3
cat rootfs/etc/fstab
sudo mv fstab rootfs/etc
cat rootfs/etc/fstab
sync

echo "Mounting efi partition"
sudo mkdir -p rootfs/boot/efi
sudo mount -o rw ${efi_dev} rootfs/boot/efi


echo "Chroot ......"
sudo mount -o bind /dev rootfs/dev
sudo mount -o bind /proc rootfs/proc
sudo mount -o bind /sys rootfs/sys

echo 'df
grub-install /dev/loop100 
update-grub
sync
exit
'|sudo chroot rootfs

#sudo chroot rootfs

sudo umount rootfs/dev
sudo umount rootfs/sys
sudo umount rootfs/proc
sudo sync

echo "Umounting loopback device"
sudo sync
sleep 3
sudo umount rootfs/boot/efi
sudo umount rootfs
sudo losetup -d /dev/loop100
