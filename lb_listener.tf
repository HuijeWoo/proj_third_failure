resource "aws_lb_listener" "outer" {
  load_balancer_arn = aws_lb.outer_lb.arn
  port              = 80 # 들어와들어와
  protocol          = "HTTP"
  depends_on = [
    aws_lb.outer_lb
  ]

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.outer_lb_tg.arn
  }
}

resource "aws_lb_listener" "inner" {
  load_balancer_arn = aws_lb.inner_lb.arn
  port              = 80 # 들어와들어와
  protocol          = "HTTP"
  depends_on = [
    aws_lb.inner_lb
  ]

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.inner_lb_tg.arn
  }
}

