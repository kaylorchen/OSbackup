#!/bin/bash
#Check if this is run with sudo, and exit otherwise
if [ "$EUID" -ne 0 ]
  then echo "Please run as root"
  exit
fi
read -p "Input image size(Uint: MiB):" number
if [ ! -n "$number" ] ; then
    echo "error"
    exit 
fi
if [ $number -lt 400 ] ; then
    echo "error, size should be larger than 400"
    exit
fi
total_Mb=$number
total_sectors=$(expr $number \* 2048)
start_sector=2048
end_sector=$(expr $total_sectors \- 34)
echo "total_sectors=${total_sectors}, start_sector=${start_sector}, \
end_sector=${end_sector}"

echo "Remove disk.img"
rm disk.img

echo "Creating empty file"
dd if=/dev/zero of=disk.img bs=1M count=$total_Mb

echo "Partitioning image"
sudo parted -s disk.img mklabel gpt
sudo parted -a none -s disk.img unit s mkpart  EFI fat32 ${start_sector} 585727
sudo parted -a none -s disk.img unit s mkpart  rootfs ext4 585728 ${end_sector}

echo "Setting partition flag"
sudo parted disk.img set 1 boot on
sudo parted disk.img set 1 esp on

echo "Associating loopback device to image"
sudo losetup /dev/loop100 --partscan --show disk.img

echo "Formatting disk.img"
sudo mkfs.fat -F 32 /dev/loop100p1
sudo mkfs.ext4 /dev/loop100p2

echo "Create a rootfs mount point"
sudo mkdir rootfs

echo "Mounting disk image rootfs partition"
sudo mount /dev/loop100p2 rootfs

echo "Create a efi mount point"
sudo mkdir -p rootfs/boot/efi

echo "Mounting disk image efi partition"
sudo mount /dev/loop100p1 rootfs/boot/efi

echo "Installing grub"
sudo grub-install --target=x86_64-efi --efi-directory=rootfs/boot/efi --removable --boot-directory=rootfs/boot --bootloader-id=grub /dev/loop100
# sudo grub-mkconfig -o rootfs/boot/grub/grub.cfg

sudo bash base.sh rootfs

echo "Umounting loopback device"
sudo umount rootfs/boot/efi
sudo umount rootfs
sudo losetup -d /dev/loop100
sudo rm rootfs -rf


sudo parted -s disk.img p
sudo fdisk -l disk.img