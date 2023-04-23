#!/bin/bash
#Check if this is run with sudo, and exit otherwise
if [ "$EUID" -ne 0 ]
  then echo "Please run as root"
  exit
fi
ROOTFS=${1}
echo "Update rootfs"
ls $ROOTFS >/dev/null 2>&1
if [ $? != "0" ]; then
    echo "./${ROOTFS} is not found, and a new root filesystem will be generated."
    bash build-base-rootfs.sh $ROOTFS
fi
bash install-user-software.sh $ROOTFS
