#!/bin/bash
dnf update -y
hostnamectl set-hostname was.example.com
dnf install pip -y
yum -y install amazon-efs-utils
pip install --upgrade pip
pip install flask gunicorn flask-cors requests pymysql
mkdir -p ${mount_point}
su -c  "echo '${was_efs_id}:/ ${mount_point} efs _netdev,tls 0 0' >> /etc/fstab"
mount ${mount_point}
chmod 755 -R ${mount_point}
chown ec2-user:ec2-user -R ${mount_point}
aws s3 cp s3://no-way-bucket/service/blind_was ${mount_point}/blind_was --recursive
aws s3 cp s3://no-way-bucket/service/was.tpl ${mount_point}
mv ${mount_point}/was.tpl ${mount_point}/blind_was.service
cp ${mount_point}/blind_was.service /etc/systemd/system/blind_was.service
systemctl daemon-reload
systemctl enable --now blind_was.service