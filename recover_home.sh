#!/bin/bash
if [ "$EUID" -ne 0 ]
  then echo "Please run as root"
  exit
fi

home_tar=${1}
dev=${DEV}
echo "device is ${dev}, home tar is ${home_tar}"

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

echo "Mounting home device"
sudo mkdir -p /mnt/home
sudo mount /dev/loop100p3 /mnt/home

echo "Uncompressing home file"
#sudo mkdir -p /mnt/home/ubuntu
#sudo chown -R 1000:1000 /mnt/home/ubuntu
#sudo tar -xvpzf $home_tar -C /mnt/home/ubuntu
sudo tar -xvpzf $home_tar -C /mnt/home --strip-components=1
sudo chown -R 1000:1000 /mnt/home/*

echo "Umounting Home device"
sudo sync
sleep 3
sudo umount /mnt/home
sudo losetup -d /dev/loop100


