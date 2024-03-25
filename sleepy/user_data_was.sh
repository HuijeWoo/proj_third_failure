#!/bin/bash
sudo dnf update -y
sudo hostnamectl set-hostname was.example.com
sudo dnf install pip -y
sudo yum -y install amazon-efs-utils
sudo pip install --upgrade pip
sudo pip install flask gunicorn flask-cors requests pymysql
sudo mkdir -p ${mount_point}
sudo su -c  "echo '${was_efs_id}:/ ${mount_point} efs _netdev,tls 0 0' >> /etc/fstab"
sudo mount -t efs -o tls ${was_efs_id}:/ ${mount_point}
sudo mount -fav
yes | sudo aws s3 cp s3://no-way-bucket/blind_was -r ${mount_point}
yes | sudo aws s3 cp s3://no-way-bucket/was.tpl ${mount_point}/
df -k
sudo chown ec2-user:ec2-user -R ${mount_point}
sudo chmod 755 -R ${mount_point}
yes | sudo mv ${mount_point}/was.tpl ${mount_point}/blind_was.service
yes | sudo cp ${mount_point}/blind_was.service /etc/systemd/system/blind_was.service
sudo systemctl daemon-reload
sudo systemctl enable --now blind_was.service