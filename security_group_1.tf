resource "aws_security_group" "public_sg" {
  name        = "public-sg"
  description = "sg for public instance"
  vpc_id      = aws_vpc.main_vpc.id
  lifecycle { create_before_destroy = true }
  depends_on = [
    aws_subnet.public
  ]
  tags = { Name = "public-sg" }
  ingress {
    protocol    = "tcp"
    from_port   = 80
    to_port     = 80
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    protocol    = "tcp"
    from_port   = 22
    to_port     = 22
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    protocol    = "tcp"
    from_port   = 443
    to_port     = 443
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group" "outer_lb_sg" {
  name        = "outer-lb-sg"
  description = "sg for outer loadbalancer"
  vpc_id      = aws_vpc.main_vpc.id
  lifecycle { create_before_destroy = true }
  tags = { Name = "outer-lb-sg" }
  ingress {
    protocol    = "tcp"
    from_port   = 80
    to_port     = 80
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    protocol    = "tcp"
    from_port   = 443
    to_port     = 443
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group" "web_private_sg" {
  name        = "web-private-sg"
  description = "sg for web private instance"
  vpc_id      = aws_vpc.main_vpc.id
  lifecycle { create_before_destroy = true }
  depends_on = [
    aws_security_group.outer_lb_sg
  ]
  tags = { Name = "web-private-sg" }
  ingress {
    protocol  = "tcp"
    from_port = 22
    to_port   = 22
    security_groups = [
      aws_security_group.outer_lb_sg.id,
      aws_security_group.public_sg.id
    ]
  }
  ingress {
    protocol  = "tcp"
    from_port = 80
    to_port   = 80
    security_groups = [
      aws_security_group.outer_lb_sg.id,
      aws_security_group.public_sg.id
    ]

  }
  ingress {
    protocol  = "tcp"
    from_port = 443
    to_port   = 443
    security_groups = [
      aws_security_group.outer_lb_sg.id,
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
