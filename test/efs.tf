resource "aws_efs_file_system" "efs_one" {
  creation_token = "unknown token"
  encrypted      = true
  tags = {
    Name = "efs_one"
  }
}

resource "aws_efs_mount_target" "mount_targets" {
  count           = length(aws_subnet.public)
  file_system_id  = aws_efs_file_system.efs_one.id
  subnet_id       = element(aws_subnet.public[*].id, count.index)
  security_groups = [aws_security_group.efs_sg.id]
}
