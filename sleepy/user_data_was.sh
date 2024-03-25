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

sudo aws s3 cp s3://no-way-bucket/service/blind_was ${mount_point}/blind_was --recursive
sudo aws s3 cp s3://no-way-bucket/service/was.tpl ${mount_point}

sudo chown ec2-user:ec2-user -R ${mount_point}
sudo chmod 755 -R ${mount_point}

# sudo sed -i '(행번호)s/.*/(변경할내용)/g' (파일명)
sudo sed -i '8s/.*/user = "root"/g' ${mount_point}/blind_was/blind_board_DAO.py
sudo sed -i '9s/.*/password = "12341234"/g' ${mount_point}/blind_was/blind_board_DAO.py
sudo sed -i '10s/.*/host = "some_rds_address"/g' ${mount_point}/blind_was/blind_board_DAO.py
sudo sed -i '11s/.*/db = "blind"/g' ${mount_point}/blind_was/blind_board_DAO.py

# sudo sed -i '(행번호)s/.*/(변경할내용)/g' (파일명)
sudo sed -i '8s/.*/user = "root"/g' ${mount_point}/blind_was/blind_member_DAO.py
sudo sed -i '9s/.*/password = "12341234"/g' ${mount_point}/blind_was/blind_member_DAO.py
sudo sed -i '10s/.*/host = "some_rds_address"/g' ${mount_point}/blind_was/blind_member_DAO.py
sudo sed -i '11s/.*/db = "blind"/g' ${mount_point}/blind_was/blind_member_DAO.py

# sudo sed -i '(행번호)s/.*/(변경할내용)/g' (파일명)
sudo sed -i '8s/.*/user = "root"/g' ${mount_point}/blind_was/blind_reply_DAO.py
sudo sed -i '9s/.*/password = "12341234"/g' ${mount_point}/blind_was/blind_reply_DAO.py
sudo sed -i '10s/.*/host = "some_rds_address"/g' ${mount_point}/blind_was/blind_reply_DAO.py
sudo sed -i '11s/.*/db = "blind"/g' ${mount_point}/blind_was/blind_reply_DAO.py

yes | sudo mv ${mount_point}/was.tpl ${mount_point}/blind_was.service
yes | sudo cp ${mount_point}/blind_was.service /etc/systemd/system/blind_was.service
sudo systemctl daemon-reload
sudo systemctl enable --now blind_was.service