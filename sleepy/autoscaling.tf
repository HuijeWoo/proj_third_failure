resource "aws_ami_from_instance" "web_ami" {
    name               = "web"
    source_instance_id = aws_instance.web_private[0].id
    depends_on = [
        aws_instance.web_private,
        aws_efs_file_system.web_efs,
        aws_efs_mount_target.web_mount
    ]
}
resource "aws_ami_from_instance" "was_ami" {
    name               = "was"
    source_instance_id = aws_instance.was_private[0].id
    depends_on = [
        aws_instance.was_private,
        aws_efs_file_system.was_efs,
        aws_efs_mount_target.was_mount
    ]
}

resource "aws_launch_configuration" "web_launch" {
  name_prefix     = "web-asg-"
  image_id        = aws_ami_from_instance.web_ami.id
  instance_type   = "t2.micro"
  #user_data       = file("user_data_web.sh")
  security_groups = [aws_security_group.web_sg.id]
  key_name = aws_key_pair.key_1.id
  depends_on = [ 
    aws_ami_from_instance.web_ami
  ]
  lifecycle {
    create_before_destroy = true
  }
}
resource "aws_autoscaling_group" "web_asg" {
    max_size = 4
    min_size = 2
    desired_capacity = 2
    vpc_zone_identifier = aws_subnet.public[*].id 
    launch_configuration = aws_launch_configuration.web_launch.name
    target_group_arns = [ aws_lb_target_group.exter_lb_tg.arn ]
    enabled_metrics = [
      "GroupMinSize",
      "GroupMaxSize",
      "GroupDesiredCapacity",
      "GroupInServiceInstances",
      "GroupTotalInstances"
    ]
    health_check_grace_period = 100
    depends_on = [
        aws_efs_file_system.web_efs,
        aws_instance.web_private
    ]
    lifecycle { 
        ignore_changes = [desired_capacity, target_group_arns]
        create_before_destroy = true
    }
    tag {
        key = "Name"
        value = "web"
        propagate_at_launch = true
    }
}
resource "aws_autoscaling_attachment" "web_asg_attach" {
  autoscaling_group_name = aws_autoscaling_group.web_asg.id
  lb_target_group_arn    = aws_lb_target_group.exter_lb_tg.arn
}

resource "aws_launch_configuration" "was_launch" {
  name_prefix = "was-asg-"
  image_id        = aws_ami_from_instance.was_ami.id
  instance_type   = "t2.micro"
  #user_data       = file("user_data_was.sh")
  security_groups = [aws_security_group.was_sg.id]
  key_name = aws_key_pair.key_1.id
  depends_on = [ 
    aws_ami_from_instance.was_ami
  ]
  lifecycle {
    create_before_destroy = true
  }
}
resource "aws_autoscaling_group" "was_asg" {
    max_size = 4
    min_size = 2
    desired_capacity = 2
    vpc_zone_identifier = aws_subnet.web_private[*].id 
    launch_configuration = aws_launch_configuration.was_launch.name
    target_group_arns = [ aws_lb_target_group.inter_lb_tg.arn ]
    enabled_metrics = [
        "GroupMinSize",
        "GroupMaxSize",
        "GroupDesiredCapacity",
        "GroupInServiceInstances",
        "GroupTotalInstances"
    ]
    health_check_grace_period = 100
    depends_on = [
        aws_efs_file_system.was_efs,
        aws_instance.was_private
    ]
    lifecycle { 
        ignore_changes = [desired_capacity, target_group_arns]
        create_before_destroy = true
    }
    tag {
        key = "Name"
        value = "was"
        propagate_at_launch = true
    }
}
resource "aws_autoscaling_attachment" "was_asg_attach" {
  autoscaling_group_name = aws_autoscaling_group.was_asg.id
  lb_target_group_arn    = aws_lb_target_group.inter_lb_tg.arn
}