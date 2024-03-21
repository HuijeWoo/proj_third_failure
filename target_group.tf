resource "aws_lb_target_group" "outer_lb_tg" {
  name     = "outer-lb-tg"
  port     = 80 # from
  protocol = "HTTP"
  vpc_id   = aws_vpc.main_vpc.id
  tags = {
    Name = "outer-lb-tg"
  }
}

resource "aws_lb_target_group" "inner_lb_tg" {
  name     = "inner-lb-tg"
  port     = 80 # from
  protocol = "HTTP"
  vpc_id   = aws_vpc.main_vpc.id
  tags = {
    Name = "inner-lb-tg"
  }
}

