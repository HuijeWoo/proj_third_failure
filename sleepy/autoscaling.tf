resource "aws_ami_from_instance" "web_ami" {
    name               = "web"
    source_instance_id = aws_instance.web_private[0].id
    depends_on = [
        aws_instance.web_private
    ]
}
resource "aws_ami_from_instance" "was_ami" {
    name               = "was"
    source_instance_id = aws_instance.was_private[0].id
    depends_on = [
        aws_instance.was_private
    ]
}

resource "aws_launch_configuration" "web_launch" {
  name     = "web-asg"
  image_id        = aws_ami_from_instance.web_ami.id
  instance_type   = "t2.micro"
  user_data       = file("user_data_web.sh")
  security_groups = [aws_security_group.web_sg.id]
  depends_on = [ 
    aws_ami_from_instance.web_ami
  ]
  lifecycle {
    create_before_destroy = true
  }
}
resource "aws_autoscaling_group" "web_asg" {
    max_size = 5
    min_size = 2
    desired_capacity = 3
    vpc_zone_identifier = [ aws_subnet.public[*].id ]
    launch_configuration = aws_launch_configuration.web_launch.name
    target_group_arns = [ aws_lb_target_group.exter_lb_tg.arn ]
    lifecycle { 
        ignore_changes = [desired_capacity, target_group_arns]
    }
}
resource "aws_autoscaling_attachment" "web_asg_attach" {
  autoscaling_group_name = aws_autoscaling_group.web_asg.id
  lb_target_group_arn    = aws_lb_target_group.exter_lb_tg.arn
}

resource "aws_launch_configuration" "was_launch" {
  name     = "was-asg"
  image_id        = aws_ami_from_instance.was_ami
  instance_type   = "t2.micro"
  user_data       = file("user_data_was.sh")
  security_groups = [aws_security_group.was_sg.id]
  depends_on = [ 
    aws_ami_from_instance.was_ami
  ]
  lifecycle {
    create_before_destroy = true
  }
}
resource "aws_autoscaling_group" "was_asg" {
    max_size = 5
    min_size = 2
    desired_capacity = 3
    vpc_zone_identifier = [ aws_subnet.web_private[*].id ]
    launch_configuration = aws_launch_configuration.was_launch.name
    target_group_arns = [ aws_lb_target_group.inter_lb_tg.arn ]
    lifecycle { 
        ignore_changes = [desired_capacity, target_group_arns]
    }
}
resource "aws_autoscaling_attachment" "was_asg_attach" {
  autoscaling_group_name = aws_autoscaling_group.was_asg.id
  lb_target_group_arn    = aws_lb_target_group.inter_lb_tg.arn
}