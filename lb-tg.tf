resource "aws_lb_target_group_attachment" "outer" {
  for_each = {
    for k, v in aws_instance.web_private_instance :
    k => v
  }
  # k => v means key : value and I only use value

  target_group_arn = aws_lb_target_group.outer_lb_tg.arn
  target_id        = each.value.id
  port             = 80 # target receive
}

resource "aws_lb_target_group_attachment" "inner" {
  for_each = {
    for k, v in aws_instance.was_private_instance :
    k => v
  }
  # k => v means key : value and I only use value

  target_group_arn = aws_lb_target_group.inner_lb_tg.arn
  target_id        = each.value.id
  port             = 80 # target receive
}

