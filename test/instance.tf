resource "aws_instance" "public_instance" {
  count                       = length(aws_subnet.public)
  ami                         = data.aws_ami.amazon_linux_2023.id
  instance_type               = "t2.micro"
  key_name                    = aws_key_pair.terra_key.id
  vpc_security_group_ids      = [aws_security_group.public_sg.id]
  subnet_id                   = element(aws_subnet.public[*].id, count.index)
  associate_public_ip_address = true
  root_block_device {
    delete_on_termination = true
    encrypted             = false
    volume_size           = 20
    volume_type           = "standard"
  }
  tags = {
    Name = "public-${count.index + 1}"
  }
  user_data = templatefile("user_data.sh", {
    efs_dns         = aws_efs_file_system.efs_one.dns_name
    efs_mount_point = "/mnt/efs/data"
    efs_id          = aws_efs_file_system.efs_one.id
  })
  depends_on = [
    aws_efs_mount_target.mount_targets
  ]
}

data "aws_ami" "amazon_linux_2023" {
  most_recent = true
  owners      = ["amazon"]
  filter {
    name   = "architecture"
    values = ["x86_64"]
  }
  filter {
    name   = "name"
    values = ["al2023-ami-2023*"]
  }
  filter {
    name   = "root-device-type"
    values = ["ebs"]
  }
  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}
