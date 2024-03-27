#cloud-config
package_update: true
package_upgrade: true
runcmd:
- yum install -y amazon-efs-utils
- yum install -y nfs-utils
- yum install pip -y
- pip install --upgrade pip
- pip install flask gunicorn flask-cors requests pymysql
- hostnamectl set-hostname was.example.com
- file_system_id_1=${was_efs_id}
- efs_mount_point_1=${mount_point}
- username_=${username}
- password_=${password}
- host_=${host}
- database_name_=${database_name}
- mkdir -p "${efs_mount_point_1}"
- test -f "/sbin/mount.efs" && printf "\n${file_system_id_1}:/ ${efs_mount_point_1} efs tls,_netdev\n" >> /etc/fstab || printf "\n${file_system_id_1}.efs.ap-northeast-2.amazonaws.com:/ ${efs_mount_point_1} nfs4 nfsvers=4.1,rsize=1048576,wsize=1048576,hard,timeo=600,retrans=2,noresvport,_netdev 0 0\n" >> /etc/fstab
- test -f "/sbin/mount.efs" && grep -ozP 'client-info]\nsource' '/etc/amazon/efs/efs-utils.conf'; if [[ $? == 1 ]]; then printf "\n[client-info]\nsource=liw\n" >> /etc/amazon/efs/efs-utils.conf; fi;
- retryCnt=15; waitTime=30; while true; do mount -a -t efs,nfs4 defaults; if [ $? = 0 ] || [ $retryCnt -lt 1 ]; then echo File system mounted successfully; break; fi; echo File system not available, retrying to mount.; ((retryCnt--)); sleep $waitTime; done;
- chmod 755 -R ${mount_point}
- chown ec2-user:ec2-user -R ${mount_point}
- aws s3 cp s3://no-way-bucket/service/blind_was "${efs_mount_point_1}"/blind_was --recursive
- aws s3 cp s3://no-way-bucket/service/was.tpl "${efs_mount_point_1}"
- sed -i '8s/.*/user = "${username_}"/g' "${efs_mount_point_1}"/blind_was/blind_board_DAO.py
- sed -i '9s/.*/password = "${password_}"/g' "${efs_mount_point_1}"/blind_was/blind_board_DAO.py
- sed -i '10s/.*/host = "${host_}"/g' "${efs_mount_point_1}"/blind_was/blind_board_DAO.py
- sed -i '11s/.*/db = "${database_name_}"/g' "${efs_mount_point_1}"/blind_was/blind_board_DAO.py
- sed -i '8s/.*/user = "${username_}"/g' "${efs_mount_point_1}"/blind_was/blind_member_DAO.py
- sed -i '9s/.*/password = "${password_}"/g' "${efs_mount_point_1}"/blind_was/blind_member_DAO.py
- sed -i '10s/.*/host = "${host_}"/g' "${efs_mount_point_1}"/blind_was/blind_member_DAO.py
- sed -i '11s/.*/db = "${database_name_}"/g' "${efs_mount_point_1}"/blind_was/blind_member_DAO.py
- sed -i '8s/.*/user = "${username_}"/g' "${efs_mount_point_1}"/blind_was/blind_reply_DAO.py
- sed -i '9s/.*/password = "${password_}"/g' "${efs_mount_point_1}"/blind_was/blind_reply_DAO.py
- sed -i '10s/.*/host = "${host_}"/g' "${efs_mount_point_1}"/blind_was/blind_reply_DAO.py
- sed -i '11s/.*/db = "${database_name_}"/g' "${efs_mount_point_1}"/blind_was/blind_reply_DAO.py
- mv "${efs_mount_point_1}"/was.tpl "${efs_mount_point_1}"/blind_was.service
- cp "${efs_mount_point_1}"/blind_was.service /etc/systemd/system/blind_was.service
- systemctl daemon-reload
- systemctl enable --now blind_was.service