resource "aws_security_group" "public_sg" {
  name        = "public-sg"
  description = "sg for instance"
  vpc_id      = aws_vpc.main_vpc.id
  lifecycle { create_before_destroy = true }
  depends_on = [
    aws_subnet.public
  ]
  tags = { Name = "public-sg" }
}
resource "aws_security_group_rule" "public_in_80" {
  type              = "ingress"
  to_port           = 80
  protocol          = "tcp"
  from_port         = 80
  security_group_id = aws_security_group.public_sg.id
  cidr_blocks       = ["0.0.0.0/0"]
}
resource "aws_security_group_rule" "public_in_22" {
  type              = "ingress"
  to_port           = 22
  protocol          = "tcp"
  from_port         = 22
  security_group_id = aws_security_group.public_sg.id
  cidr_blocks       = ["0.0.0.0/0"]
}
resource "aws_security_group_rule" "public-to-efs" {
  type                     = "egress"
  from_port                = 2049
  to_port                  = 2049
  protocol                 = "tcp"
  security_group_id        = aws_security_group.public_sg.id
  source_security_group_id = aws_security_group.efs_sg.id
}

resource "aws_security_group_rule" "public-out-all" {
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  security_group_id = aws_security_group.public_sg.id
  cidr_blocks       = ["0.0.0.0/0"]
}

resource "aws_security_group" "efs_sg" {
  name        = "efs-sg"
  description = "sg for efs"
  vpc_id      = aws_vpc.main_vpc.id
  lifecycle { create_before_destroy = true }
  #depends_on = [ ]
  tags = { Name = "efs-sg" }
}
resource "aws_security_group_rule" "efs-from-public" {
  type                     = "ingress"
  from_port                = 2049
  to_port                  = 2049
  protocol                 = "tcp"
  security_group_id        = aws_security_group.efs_sg.id
  source_security_group_id = aws_security_group.public_sg.id
}
resource "aws_security_group_rule" "efs_out_all" {
  type              = "egress"
  to_port           = 0
  protocol          = "-1"
  from_port         = 0
  security_group_id = aws_security_group.efs_sg.id
  cidr_blocks       = ["0.0.0.0/0"]
}
