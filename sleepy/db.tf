# db 관련 내용 전부 퍼옴.
# https://isc9511.tistory.com/167

resource "aws_db_subnet_group" "db_subnet_group_1" {
  name = "sleep-db-subnet-group"
  subnet_ids = aws_subnet.was_private[*].id
  tags = {
    Name = "sleepy_db_subnet_1"
  }
}

resource "aws_rds_cluster" "aurora_mysql_db" {
  cluster_identifier = "database-1" 
  engine_mode = "provisioned" 
  db_subnet_group_name = aws_db_subnet_group.db_subnet_group_1.name 
  vpc_security_group_ids = [aws_security_group.db_sg.id]
  engine = "aurora-mysql"
  engine_version = "5.7.mysql_aurora.2.11.1"
  availability_zones = var.az_list
  database_name = "blind" # 이름 명칭 구문 까다로움 (특수문자 들어가면 안됌)
  master_username = "root" 
  master_password = "12341234"
  skip_final_snapshot = true # RDS 삭제 시, 스냅샷 생성 X (true값으로 설정 시, terraform destroy 정상 수행 가능)
  port = 3306
  depends_on = [
    aws_db_subnet_group.db_subnet_group_1
  ]
  lifecycle {
    create_before_destroy = true
  }
}

output "rds_writer_endpoint" { # rds cluster의 writer 인스턴스 endpoint 추출 (mysql 설정 및 Three-tier 연동파일에 정보 입력 필요해서 추출)
  value = aws_rds_cluster.aurora_mysql_db.endpoint # 해당 추출값은 terraform apply 완료 시 또는 terraform output rds_writer_endpoint로 확인 가능
}

resource "aws_rds_cluster_instance" "aurora_mysql_db_instance" {
  count = 2 # RDS Cluster에 속한 총 2개의 DB 인스턴스 생성 (Reader/Writer로 지정)
  identifier = "database-1-${count.index}" # Instance의 식별자명 (count index로 0번부터 1씩 상승)
  cluster_identifier = aws_rds_cluster.aurora_mysql_db.id # 소속될 Cluster의 ID 지정
  instance_class = "db.t3.small" # DB 인스턴스 Class (메모리 최적화/버스터블 클래스 선택 없이 type명만 적으면 됌)
  engine             = aws_rds_cluster.aurora_mysql_db.engine
  engine_version     = aws_rds_cluster.aurora_mysql_db.engine_version
  depends_on = [
    aws_db_subnet_group.db_subnet_group_1
  ]
  lifecycle {
    create_before_destroy = true
  }
}