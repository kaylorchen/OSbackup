#!/bin/bash
sleep 15

#Check if this is run with sudo, and exit otherwise
if [ "$EUID" -ne 0 ]; then
  echo "Please run as root"
  exit
fi

SCRIPT=$(readlink -f "$0")
echo SCRIPT is $SCRIPT
CUR_DIR=$(dirname "$SCRIPT")
echo CUR_DIR is $CUR_DIR

AUDIO_PATH=${CUR_DIR}/reebotic_audio

source ${CUR_DIR}/config.sh

if ls ${CUR_DIR}/turn_on_robot_speaker; then
  echo "Opening robot speaker"
  ${CUR_DIR}/turn_on_robot_speaker
else
  echo "turn_on_robot_speaker: no such this file"
fi

# 设置音量
amixer -c ${SOUND_CARD_NUMBER} set ${SOUND_CARD_CTRL_PARAMETER} ${SOUND_CARD_VOLUME}

# 判断device选项
ls ${DEVICE} >/dev/null 2>&1
if [ $? != "0" ]; then
  aplay -Dplughw:${SOUND_CARD_NUMBER},${SOUND_CARD_SUBNUMBER} ${AUDIO_PATH}/device_err.wav
  exit
fi

# 判断image选项
ls ${CUR_DIR}/${IMAGE} >/dev/null 2>&1
if [ $? != "0" ]; then
  aplay -Dplughw:${SOUND_CARD_NUMBER},${SOUND_CARD_SUBNUMBER} ${AUDIO_PATH}/image_err.wav
  exit
fi
image=${CUR_DIR}/${IMAGE}
echo image is ${image}

# 开始烧写镜像
aplay -Dplughw:${SOUND_CARD_NUMBER},${SOUND_CARD_SUBNUMBER} ${AUDIO_PATH}/start_flash.wav
aplay -Dplughw:${SOUND_CARD_NUMBER},${SOUND_CARD_SUBNUMBER} ${AUDIO_PATH}/notice.wav

echo "Flashing image"
sudo bash ${CUR_DIR}/flash.sh ${DEVICE} ${image} &
echo "Sleep for 5 seconds"
sleep 5
while true; do
  if ps aux | grep "dd *of=${DEVICE}" | grep -v "grep"; then
    echo "dd is running"
    aplay -Dplughw:${SOUND_CARD_NUMBER},${SOUND_CARD_SUBNUMBER} ${AUDIO_PATH}/flashing.wav
    sleep 10
  else
    echo "dd is compeleted"
    break
  fi
done

echo "Extending partition"
sudo bash ${CUR_DIR}/extended_partition.sh ${DEVICE} 1

aplay -Dplughw:${SOUND_CARD_NUMBER},${SOUND_CARD_SUBNUMBER} ${AUDIO_PATH}/finished.wav
while true; do
  aplay -Dplughw:${SOUND_CARD_NUMBER},${SOUND_CARD_SUBNUMBER} ${AUDIO_PATH}/finished_reboot.wav
  sleep 3
done
