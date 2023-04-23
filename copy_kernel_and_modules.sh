#!/bin/bash
#Check if this is run with sudo, and exit otherwise
if [ "$EUID" -ne 0 ]
  then echo "Please run as root"
  exit
fi
cur_dir=$(pwd)
ver=$(ls -l /boot | grep 'vmlinuz ->' | awk -F 'vmlinuz-' '{print $2}')
echo "kernel version is $ver"
mkdir -p linux/kernel

list=$(ls -l /boot | grep "${ver}" | awk -F ' ' '{print $9}' | sed ':label;N;s/\n/ /;b label' )
echo "copy list: $list"
cd /boot/
sudo rsync -avz ${list} ${cur_dir}/linux/kernel
cd $cur_dir

sudo rsync -avzR /lib/modules/${ver} ${cur_dir}/linux/