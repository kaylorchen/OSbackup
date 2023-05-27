#!/bin/bash

#Check if this is run with sudo, and exit otherwise
if [ "$EUID" -ne 0 ]; then
  echo "Please run as root"
  exit
fi
dev=${1}
image=${2}

format="Y"
if [[ "$format" == "Y" || "$format" == "y" ]]; then

  echo "device is ${dev}, and image is ${image}"

  ls ${image} >/dev/null 2>&1
  if [ $? != "0" ]; then
    echo "no such file: $image"
    exit
  fi

  df | grep ${dev} >/dev/null 2>&1
  if [ $? = "0" ]; then
    mount_list=$(df | grep ${dev} | awk -F ' ' '{ print $1}')
    for line in $mount_list; do
      echo "umounting $line"
      umount $line
    done
  fi
  if [ "${image##*.}"x = "gz"x ]; then
    echo "gunzip and dd"
    gunzip -c ${image} | dd of=${dev}
  else
    echo "dd ${image}"
    dd if=${image} of=${dev}
  fi

fi
