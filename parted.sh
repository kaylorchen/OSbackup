#!/bin/bash
if [ "$EUID" -ne 0 ]
  then echo "Please run as root"
  exit
fi
if [ -z ${1} ]; then
    echo Pls add the 2nd para,: ./parted.sh /dev/xxxx
    exit
fi
device=${1}
ls ${device}
if [ $? -ne 0 ] ;then
    echo ${device} does not exist.
    exit
fi
total_sectors=$(sudo fdisk -l ${device} | grep sectors | grep /dev | awk -F ',' '{print $3}' | awk '{print $1}')
start_sector=2048
end_sector=$(expr $total_sectors \- 34)
mid_sector_left=$(expr $end_sector \/ 2)
mid_sector_right=$(expr $mid_sector_left \+ 1)
echo "total_sectors=${total_sectors}, start_sector=${start_sector}, \
mid_sector_left=${mid_sector_left}, mid_sector_right=${mid_sector_right},\
end_sector=${end_sector}"
# exit
echo "${device} will be formatted"
read -p "Do you want to continue? [N/y] " confirm
if [[ ${confirm} == "y" ]]; then
    echo "-----------------"
    echo "Partitioning image"
    sudo parted -s ${device} mklabel gpt
    sudo parted -a none -s ${device} unit s mkpart  EFI fat32 ${start_sector} 585727
    sudo parted -a none -s ${device} unit s mkpart  rootfs ext4 585728 ${mid_sector_left}
    sudo parted -a none -s ${device} unit s mkpart  home ext4 ${mid_sector_right} ${end_sector}

    echo "Setting partition flag"
    sudo parted ${device} set 1 boot on
    sudo parted ${device} set 1 esp on

    echo "Associating loopback device to image"
    sudo losetup /dev/loop100 --partscan --show ${device}

    echo "Formatting"
    sudo mkfs.fat -F 32 /dev/loop100p1
    sudo mkfs.ext4 /dev/loop100p2
    sudo mkfs.ext4 /dev/loop100p3

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
    sudo grub-mkconfig -o rootfs/boot/grub/grub.cfg

    echo "Umounting loopback device"
    sudo umount rootfs/boot/efi
    sudo umount rootfs
    sudo losetup -d /dev/loop100
    sudo rm rootfs -rf

    sudo parted -s ${device} p
    sudo fdisk -l ${device}

else
    echo "exit"
    exit
fi
echo "****************"