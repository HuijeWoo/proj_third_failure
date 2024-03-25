#!/bin/bash
sudo dnf update -y
sudo hostnamectl set-hostname web.example.com
sudo dnf install pip -y
sudo yum -y install amazon-efs-utils
sudo pip install --upgrade pip
sudo pip install flask gunicorn flask-cors requests pymysql
sudo mkdir -p ${mount_point}
sudo su -c  "echo '${was_efs_id}:/ ${mount_point} efs _netdev,tls 0 0' >> /etc/fstab"
sudo mount -t efs -o tls ${was_efs_id}:/ ${mount_point}
df -k