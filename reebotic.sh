#!/bin/bash

#Check if this is run with sudo, and exit otherwise
if [ "$EUID" -ne 0 ]; then
  echo "Please run as root"
  exit
fi
dev=${1}
image=${2}

echo "Flashing image"
sudo bash ./flash.sh ${dev} ${image}

echo "Extending partition"
sudo bash ./extended_partition.sh ${dev} 1