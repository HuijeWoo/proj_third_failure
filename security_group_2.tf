
resource "aws_security_group" "inner_lb_sg" {
  name        = "inner-lb-sg"
  description = "sg for inner loadbalancer"
  vpc_id      = aws_vpc.main_vpc.id
  lifecycle { create_before_destroy = true }
  tags = { Name = "inner-lb-sg" }
  depends_on = [
    aws_security_group.web_private_sg
  ]
  ingress {
    protocol  = "tcp"
    from_port = 22
    to_port   = 22
    security_groups = [
      aws_security_group.web_private_sg.id,
      aws_security_group.public_sg.id
    ]
  }
  ingress {
    protocol  = "tcp"
    from_port = 80
    to_port   = 80
    security_groups = [
      aws_security_group.web_private_sg.id,
      aws_security_group.public_sg.id
    ]

  }
  ingress {
    protocol  = "tcp"
    from_port = 443
    to_port   = 443
    security_groups = [
      aws_security_group.web_private_sg.id,
      aws_security_group.public_sg.id
    ]

  }
  egress {
    from_port = 0
    to_port   = 0
    protocol  = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group" "was_private_sg" {
  name        = "was-private-sg"
  description = "sg for was private instance"
  vpc_id      = aws_vpc.main_vpc.id
  lifecycle { create_before_destroy = true }
  depends_on = [
    aws_security_group.inner_lb_sg
  ]
  tags = { Name = "was-private-sg" }
  ingress {
    protocol  = "tcp"
    from_port = 22
    to_port   = 22
    security_groups = [
      aws_security_group.inner_lb_sg.id,
      aws_security_group.public_sg.id
    ]
  }
  ingress {
    protocol  = "tcp"
    from_port = 80
    to_port   = 80
    security_groups = [
      aws_security_group.inner_lb_sg.id,
      aws_security_group.public_sg.id
    ]
  }
  ingress {
    protocol  = "tcp"
    from_port = 443
    to_port   = 443
    security_groups = [
      aws_security_group.inner_lb_sg.id,
      aws_security_group.public_sg.id
    ]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}
