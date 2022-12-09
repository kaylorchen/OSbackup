# Ubuntu系统备份和恢复

## 说明

本项目对Ubuntu系统进行备份和恢复，原则上可以对任何linux系统进行备份和恢复。<br>
本项目默认的用户名是ubuntu，uid和gid都是1000，恢复脚本需要用到。<br>
本项目对硬盘进行分区，小部分efi分区，两个平均大小的ext4分区作为rootfs和home。

## 备份

克隆该项目，运行备份脚本
```bash
sudo bash backup_rootfs.sh
sudo bash backup_home.sh
```
注意，备份home目录的时候，本项目仅仅是备份了简单配置文件。如果需要完整备份，请修改脚本中的打包内容
```bash
sudo tar -cvpzf ${home_tar} --exclude=${home_tar} \
--exclude=/home/${user}/.cache \
/home/${user}/.[!.]*
改成
sudo tar -cvpzf ${home_tar} --exclude=${home_tar} \
/home
```
# 恢复
## 刻录Ubuntu安装盘
本项目使用的是ubuntu20.04.4的安装盘作为恢复启动系统，其他安装盘并未测试。制作启动盘请自行谷歌

## 预备工作
把本项目和硬件备份的文件放到另一个U盘中（U盘的分区如果是windows分区，建议使用exfat文件系统，因为传统的fat系统最大支持4G文件）。等安装盘启动之后，使用try Ubuntu进入系统。
插入备份U盘。这里我们默认需要把系统安装到/dev/nvme0n1上,打开终端，设置环境变量DEV=/dev/nvme0n1（根据你的具体情况设置相应的环境变量）
```bash
sudo su root
export DEV=/dev/nvme0n1
```

## 分区
运行分区脚本
```bash
bash parted.sh
```

## 恢复系统文件
```bash
bash recover_rootfs.sh your_rootfs.tar.gz
bash recover_home.sh your_home.tar.gz
```
注意：恢复home目录的时候，我们的恢复脚本仅支持单用户的模式，并且该用户的uid和gid都需要为1000.<br>
***recover_home.sh***脚本中的**sudo chown -R 1000:1000 /mnt/home/***， 需要根据你的实际情况进行权限的修改。

## 修复引导
```bash
bash repair.sh
reboot
```

## Note：
### 更新引导
重启电脑之后，可以使用指令**update-grub**更新一次引导
### 实时内核
使用实时内核的时候，出现内核没有签名不能加载的情况，这个原因是因为BIOS有一个安全启动的选项，需要进入BIOS去禁用他。英特尔的NUC可以在开机时按下F2进入BIOS设置。
### Ctrl+Alt+T响应超时问题
这个问题可能是由于装了nomachine和虚拟桌面的原因。进入系统之后。打开“Startup Applications Preferencs”, 添加或者修改指令
```bash
/usr/bin/gnome-keyring-daemon  -d -l
```
