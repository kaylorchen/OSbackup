#!/bin/bash
#Check if this is run with sudo, and exit otherwise
if [ "$EUID" -ne 0 ]
  then echo "Please run as root"
  exit
fi
time=$(date +%Y-%m+%d)
user=${SUDO_USER}

home_tar=$(pwd)/ubuntu_home@${time}.tar.gz

echo "tar a home package: ${home_tar}"
sudo tar -cvpzf ${home_tar} --exclude=${home_tar} \
--exclude=$(pwd) \
/home/${user}
sudo sync
echo "------------------------"

