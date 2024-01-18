#!/bin/bash

#
# Webサーバを初期化
#

#------------------------------------------------
# 全パッケージ更新
#------------------------------------------------
yum update -y

#------------------------------------------------
# 基本設定
#------------------------------------------------
# タイムゾーンを東京
timedatectl set-timezone Asia/Tokyo
sed -i 's/ZONE="UTC"/ZONE="Asia\/Tokyo"/g' /etc/sysconfig/clock

# 言語を日本語化
localectl set-locale LANG=ja_JP.utf8
source /etc/locale.conf
sed -i 's/LANG="en_US.UTF-8"/LANG="ja_JP.UTF-8"/g' /etc/sysconfig/i18n

# スワップ領域を作成
# mkdir /var/swap/
# dd if=/dev/zero of=/var/swap/swap0 bs=1M count=1024
# chmod 600 /var/swap/swap0
# mkswap /var/swap/swap0
# swapon /var/swap/swap0
# echo "/var/swap/swap0 swap swap defaults 0 0" >> /etc/fstab

# yum-cron
yum install -y yum-cron
sed -i 's/update_cmd = default/update_cmd = security/g' /etc/yum/yum-cron.conf
sed -i 's/apply_updates = no/apply_updates = yes/g' /etc/yum/yum-cron.conf
systemctl start yum-cron
systemctl enable yum-cron

# コマンドを入れる
yum install -y git htop


#------------------------------------------------
# Apacheを入れる
#------------------------------------------------
yum install -y httpd
systemctl start httpd
systemctl enable httpd
