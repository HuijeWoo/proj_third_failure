resource "aws_lb" "exter_lb" {
    name               = "exter-lb"
    internal           = false
    load_balancer_type = "application"
    security_groups    = [aws_security_group.exter_lb_sg.id]
    subnets            = aws_subnet.public[*].id
    depends_on = [
        aws_security_group.exter_lb_sg,
        aws_lb_target_group.exter_lb_tg
    ]
}
resource "aws_lb_listener" "exter_listen_1" {
    load_balancer_arn = aws_lb.exter_lb.arn
    port              = 80
    protocol          = "HTTP"
    depends_on = [
        aws_lb.exter_lb
    ]
    default_action {
        type             = "forward"
        target_group_arn = aws_lb_target_group.exter_lb_tg.arn
    }
}
resource "aws_lb_target_group" "exter_lb_tg" {
  name     = "exter-lb-tg"
  port     = 8080 # from
  protocol = "HTTP"
  vpc_id   = aws_vpc.vpc_1.id
  tags = {
    Name = "exter-lb-tg"
  }
}
resource "aws_lb_target_group_attachment" "exter" {
    for_each = {
        for k, v in aws_instance.web_private : k => v
    }
    target_group_arn = aws_lb_target_group.exter_lb_tg.arn
    target_id        = each.value.id
    port             = 8080
}

# 의도 : (바깥 80) -> (external lb) -> (web 8080 수신)

resource "aws_lb" "inter_lb" {
    name               = "inter-lb"
    internal           = true
    load_balancer_type = "application"
    security_groups    = [aws_security_group.inter_lb_sg.id]
    subnets            = aws_subnet.web_private[*].id
    depends_on = [
        aws_security_group.inter_lb_sg,
        aws_lb_target_group.inter_lb_tg
    ]
}
resource "aws_lb_listener" "inter_listen_1" {
    load_balancer_arn = aws_lb.inter_lb.arn
    port              = 8080
    protocol          = "HTTP"
    depends_on = [
        aws_lb.inter_lb
    ]
    default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.inter_lb_tg.arn
    }
}
resource "aws_lb_target_group" "inter_lb_tg" {
  name     = "inter-lb-tg"
  port     = 2222 # from
  protocol = "HTTP"
  vpc_id   = aws_vpc.vpc_1.id
  tags = {
    Name = "inter-lb-tg"
  }
}
resource "aws_lb_target_group_attachment" "inter" {
    for_each = {
        for k, v in aws_instance.was_private : k => v
    }
    target_group_arn = aws_lb_target_group.inter_lb_tg.arn
    target_id        = each.value.id
    port             = 2222
}

# 의도 : (web 8080 발신) -> (internal lb) -> (was 2222 수신)


