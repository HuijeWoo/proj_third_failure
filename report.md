

[구성 미리보기]

<구성도 한 장>


[구성 상세 - terraform]

1) 변수 & 기본
- variable
var.public_subnet,
var.web_subnet,
var.was_subnet,
var.db_subnet,
var.azs,
var.region,
var.testbed_tags,
var.web_asg_tags,
var.app_asg_tags,
var.bastion_layer_tags,
var.web_layer_tags,
var.app_layer_tags,
var.key_name,
var.private_key_location,
var.efs_mount_point,
var.dest_key,
var.board_file_paths,
var.dao_file_paths,
var.dest_dummy_data,

- data
data.aws_ami.amazon_linux_2023

- output
ext_lb_dns_name,
int_lb_dns_name,
bastion_instance_id,
web_instance_id,
app_instance_id,
web_instance_ip,
app_instance_ip,
rds_endpoint,
rds_address

- key
aws_key_pair.project_key

2) 네트워크
- vpc
aws_vpc.project_vpc

- subnet
aws_subnet.public,
aws.subnet.web,
aws_subnet_was,
aws_subnet_db 

- route table
aws_route_table.public_rt,
aws_route_table.private_rt,
aws_route_table_association.publi_subnet_asso,
aws_route_table_association.web_subnet_asso,
aws_route_table_association.was_subnet_asso,
aws_route_table_association.db_subnet_asso

- gateway
aws_internet_gateway.igw,
aws_eip.project_nat_eip,
aws_nat_gateway.ngw

3) 인스턴스 유저 데이터
- user_data_file
user_data_bastion.sh,
user_data_web.sh,
user_data_was.sh

- security group
aws_security_group.bastion_sg,
aws_security_group.e_elb_sg,
aws_security_group.web_sg,
aws_security_group.i_elb_sg,
aws_security_group.was_sg,
aws_security_group.db_sg,
aws_security_group.web_efs_sg,
aws_security_group.was_efs_sg

- instance
aws_instance.project_bastion,
aws_instance.project_web,
aws_instance.project_was,

4) 로드 밸런서
- load balancer
aws_alb.external_lb,
aws_lb_target_group.ext_tg,
aws_lb_listener.ext_listener,
aws_alb.internal_lb,
aws_lb_target_group.int_tg,
aws_lb_listener.int_listener


5) EFS file system
- efs file system
aws_efs_file_system.web_efs,
aws_efs_mount_target.web_mount,
aws_efs_file_system.was_efs,
aws_efs_mount_target.was_mount

6) RDS
- rds
aws_db_instance.blind_rds,
aws_db_subnet_group.default,

- dummy data
dummy_data.sh

7) 서비스
- service python script
(생략)

- service
null_resource.copy_files,
null_resource.copy_web_service,
null_resource.copy_was_service,
null_resource.define_lb_dns,
null_resource.define_end_point,
null_resource.input_dummy_data

8) AMI & 오토 스케일링
- ami
aws_ami_from_instance.web_ami,
aws_ami_from_instance.was_ami

- launch
aws_launch_configuration.web,
aws_launch_configuration.was,

- auto scaling group
aws_autoscaling_group.web,
aws_autoscaling_group.was

[계획과 다른 부분]
1) grafana x, prometheus x, s3 x, eks x

[계획과 다른 부분 - 일정]
1) 


[ 후기 - 느낀점 혹은 아쉬운 점, 향후 보완할 부분]
1) monitoring
