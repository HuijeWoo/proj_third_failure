[Unit]
Description=project Blind python Service
After=multi-user.target

[Service]
Type=idle
WorkingDirectory=/home/ec2-user/service/blind_web
ExecStart=/usr/bin/python3 -u /home/ec2-user/service/blind_web/blind.py
StandardOutput=file:/home/ec2-user/service/blind_web/blind_test.log 
StandardError=file:/home/ec2-user/service/blind_web/blind_test_error.log 


[Install]
WantedBy=multi-user.target