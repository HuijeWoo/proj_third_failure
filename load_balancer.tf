resource "aws_lb" "outer_lb" {
  name               = "outer-lb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.outer_lb_sg.id]
  subnets            = aws_subnet.public[*].id

  depends_on = [
    aws_security_group.outer_lb_sg,
    aws_lb_target_group.outer_lb_tg,
    aws_instance.web_private_instance
  ]
}

resource "aws_lb" "inner_lb" {
  name               = "inner-lb"
  internal           = true
  load_balancer_type = "application"
  security_groups    = [aws_security_group.inner_lb_sg.id]
  subnets            = aws_subnet.web_private[*].id

  depends_on = [
    aws_security_group.inner_lb_sg,
    aws_lb_target_group.inner_lb_tg,
    aws_instance.was_private_instance
  ]
}

