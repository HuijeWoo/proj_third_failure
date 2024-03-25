resource "aws_instance" "public" {
    #count                       = length(aws_subnet.public)
    count = 1
    ami                         = data.aws_ami.amazon_linux_2023.id
    instance_type               = var.basic_instance_type[0]
    key_name                    = aws_key_pair.key_1.id
    vpc_security_group_ids      = [aws_security_group.public_sg.id]
    subnet_id                   = element(aws_subnet.public[*].id, count.index)
    associate_public_ip_address = true
    iam_instance_profile = "sleepy_ec2_s3_role"
    root_block_device {
        delete_on_termination = true
        encrypted             = false
        volume_size           = 20
        volume_type           = "standard"
    }
    lifecycle {
        create_before_destroy = true
    }
    depends_on = [
        aws_subnet.public,
        aws_internet_gateway.igw_1
    ]
    tags = {
        Name = "public-${count.index + 1}"
    }
}
resource "aws_instance" "web_private" {
    #count                       = length(aws_subnet.web_private)
    count = 1
    ami                         = data.aws_ami.amazon_linux_2023.id
    instance_type               = var.basic_instance_type[0]
    key_name                    = aws_key_pair.key_1.id
    vpc_security_group_ids      = [aws_security_group.web_sg.id]
    subnet_id                   = element(aws_subnet.web_private[*].id, count.index)
    associate_public_ip_address = false
    iam_instance_profile = "sleepy_ec2_s3_role"
    root_block_device {
        delete_on_termination = true
        encrypted             = false
        volume_size           = 20
        volume_type           = "standard"
    }
    lifecycle {
        create_before_destroy = true
    }
    depends_on = [
        aws_efs_file_system.web_efs,
        aws_subnet.web_private,
        aws_nat_gateway.ngw_1
    ]
    user_data = templatefile("./user_data_web.sh", {
        web_efs_id = aws_efs_file_system.web_efs.id,
        mount_point = var.efs_mount_point
  })

    tags = {
        Name = "web-private-${count.index + 1}"
    }
}
resource "aws_instance" "was_private" {
    #count                       = length(aws_subnet.was_private)
    count = 1
    ami                         = data.aws_ami.amazon_linux_2023.id
    instance_type               = var.basic_instance_type[0]
    key_name                    = aws_key_pair.key_1.id
    vpc_security_group_ids      = [aws_security_group.was_sg.id]
    subnet_id                   = element(aws_subnet.was_private[*].id, count.index)
    associate_public_ip_address = false
    iam_instance_profile = "sleepy_ec2_s3_role"
    root_block_device {
        delete_on_termination = true
        encrypted             = false
        volume_size           = 20
        volume_type           = "standard"
    }
    lifecycle {
        create_before_destroy = true
    }
    depends_on = [
        aws_efs_file_system.was_efs,
        aws_subnet.was_private,
        aws_nat_gateway.ngw_1
    ]
    user_data = templatefile("./user_data_was.sh", {
        was_efs_id = aws_efs_file_system.was_efs.id,
        mount_point = var.efs_mount_point
  })

    tags = {
        Name = "was-private-${count.index + 1}"
    }
}
