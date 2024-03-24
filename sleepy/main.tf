resource "aws_instance" "public" {
    count                       = length(aws_subnet.public)
    ami                         = data.aws_ami.amazon_linux_2023.id
    instance_type               = var.basic_instance_type[0]
    key_name                    = aws_key_pair.terra_key.id
    vpc_security_group_ids      = [aws_security_group.public_sg.id]
    subnet_id                   = element(aws_subnet.public[*].id, count.index)
    associate_public_ip_address = true
    root_block_device {
        delete_on_termination = true
        encrypted             = false
        volume_size           = 20
        volume_type           = "standard"
    }
    lifecycle {
        create_before_destroy = true
    }
    tags = {
        Name = "public-${count.index + 1}"
    }
}
resource "aws_instance" "web_private" {
    count                       = length(aws_subnet.web_private)
    ami                         = data.aws_ami.amazon_linux_2023.id
    instance_type               = var.basic_instance_type[0]
    key_name                    = aws_key_pair.terra_key.id
    vpc_security_group_ids      = [aws_security_group.web_private_sg.id]
    subnet_id                   = element(aws_subnet.web_private[*].id, count.index)
    associate_public_ip_address = false
    root_block_device {
        delete_on_termination = true
        encrypted             = false
        volume_size           = 20
        volume_type           = "standard"
    }
    lifecycle {
        create_before_destroy = true
    }
    tags = {
        Name = "web-private-${count.index + 1}"
    }
}
resource "aws_instance" "was_private" {
    count                       = length(aws_subnet.was_private)
    ami                         = data.aws_ami.amazon_linux_2023.id
    instance_type               = var.basic_instance_type[0]
    key_name                    = aws_key_pair.terra_key.id
    vpc_security_group_ids      = [aws_security_group.was_private_sg.id]
    subnet_id                   = element(aws_subnet.was_private[*].id, count.index)
    associate_public_ip_address = false
    root_block_device {
        delete_on_termination = true
        encrypted             = false
        volume_size           = 20
        volume_type           = "standard"
    }
    lifecycle {
        create_before_destroy = true
    }
    tags = {
        Name = "was-private-${count.index + 1}"
    }
}
