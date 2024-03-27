#!/bin/bash
dnf update -y
hostnamectl set-hostname web.example.com
dnf install pip -y
yum -y install amazon-efs-utils
pip install --upgrade pip
pip install flask gunicorn flask-cors requests pymysql
mkdir -p ${mount_point}
su -c  "echo '${web_efs_id}:/ ${mount_point} efs _netdev,tls 0 0' >> /etc/fstab"
mount ${mount_point}
chmod 755 -R ${mount_point}
chown ec2-user:ec2-user -R ${mount_point}
aws s3 cp s3://no-way-bucket/service/blind_web ${mount_point}/blind_web --recursive
aws s3 cp s3://no-way-bucket/service/web.tpl ${mount_point}
mv ${mount_point}/web.tpl ${mount_point}/blind_web.service
cp ${mount_point}/blind_web.service /etc/systemd/system/blind_web.service
systemctl daemon-reload
systemctl enable --now blind_web.service