resource "aws_efs_file_system" "web_efs" {
    creation_token = "web-efs"
    encrypted = true
    performance_mode = "generalPurpose"
    throughput_mode = "bursting"
    lifecycle_policy {
        transition_to_ia = "AFTER_30_DAYS"
    }
    tags = {
        Name = "web-efs"
    }
}
resource "aws_efs_file_system" "was_efs" {
    creation_token = "was-efs"
    encrypted = true
    performance_mode = "generalPurpose"
    throughput_mode = "bursting"
    lifecycle_policy {
        transition_to_ia = "AFTER_30_DAYS"
    }
    tags = {
        Name = "was-efs"
    }
}
resource "aws_efs_mount_target" "web_mount" {
    count = length(aws_subnet.web_private)
    file_system_id  = aws_efs_file_system.web_efs.id
    subnet_id      = element(aws_subnet.web_private[*].id, count.index)
    security_groups = [aws_security_group.web_efs_sg.id]
    depends_on = [
        aws_efs_file_system.web_efs,
        aws_instance.web_private
    ]
}
resource "aws_efs_mount_target" "was_mount" {
    count = length(aws_subnet.was_private)
    file_system_id  = aws_efs_file_system.was_efs.id
    subnet_id      = element(aws_subnet.was_private[*].id, count.index)
    security_groups = [aws_security_group.was_efs_sg.id]
    depends_on = [
        aws_efs_file_system.was_efs,
        aws_instance.was_private
    ]
}