/******** public ********/
resource "aws_security_group" "public_sg" {
    name        = "public-sg"
    description = "sg for public instance"
    vpc_id      = aws_vpc.vpc_1.id
    lifecycle { 
        create_before_destroy = true
    }
    depends_on = [
        aws_subnet.public
    ]
    tags = {
        Name = "public-sg" 
    }
}
resource "aws_security_group_rule" "ingr_ssh_for_public" {
    type              = "ingress"
    to_port           = var.ssh_port
    protocol          = "tcp"
    from_port         = var.ssh_port
    security_group_id = aws_security_group.public_sg.id
    cidr_blocks       = [var.ip_all]
}
resource "aws_security_group_rule" "public-out-all" {
    type              = "egress"
    from_port         = 0
    to_port           = 0
    protocol          = "-1"
    security_group_id = aws_security_group.public_sg.id
    cidr_blocks       = [var.ip_all]
}
/******** external loadbalancer ********/
resource "aws_security_group" "exter_lb_sg" {
    name        = "exter-lb-sg"
    description = "sg for external loadbalancer"
    vpc_id      = aws_vpc.vpc_1.id
    lifecycle { 
        create_before_destroy = true
    }
    depends_on = [
        aws_subnet.public
    ]
    tags = {
        Name = "exter-lb-sg" 
    }
}
resource "aws_security_group_rule" "ingr_http_for_exter_lb" {
    type              = "ingress"
    to_port           = var.http_port
    protocol          = "tcp"
    from_port         = var.http_port
    security_group_id = aws_security_group.exter_lb_sg.id
    cidr_blocks       = [var.ip_all]
}
resource "aws_security_group_rule" "exter-out-all" {
    type              = "egress"
    from_port         = 0
    to_port           = 0
    protocol          = "-1"
    security_group_id = aws_security_group.exter_lb_sg.id
    cidr_blocks       = [var.ip_all]
}
/******** web instance ********/
resource "aws_security_group" "web_sg" {
    name        = "web-sg"
    description = "sg for web instance"
    vpc_id      = aws_vpc.vpc_1.id
    lifecycle { 
        create_before_destroy = true
    }
    depends_on = [
        aws_subnet.web_private
    ]
    tags = {
        Name = "web-sg" 
    }
}
#### external-lb -> (5000 web)
resource "aws_security_group_rule" "ingr_from_exter_lb" {
    type              = "ingress"
    to_port           = 5000
    protocol          = "tcp"
    from_port         = 5000
    security_group_id = aws_security_group.web_sg.id
    source_security_group_id = aws_security_group.exter_lb_sg.id
}
####
resource "aws_security_group_rule" "ingr_ssh_for_web_with_public" {
    type              = "ingress"
    to_port           = var.ssh_port
    protocol          = "tcp"
    from_port         = var.ssh_port
    security_group_id = aws_security_group.web_sg.id
    source_security_group_id = aws_security_group.public_sg.id
}
resource "aws_security_group_rule" "web_egr_to_web_efs" {
    type                     = "egress" 
    from_port                = 2049
    to_port                  = 2049
    protocol                 = "tcp"
    security_group_id        = aws_security_group.web_sg.id
    source_security_group_id = aws_security_group.web_efs_sg.id
}
resource "aws_security_group_rule" "web-out-all" {
    type              = "egress"
    from_port         = 0
    to_port           = 0
    protocol          = "-1"
    security_group_id = aws_security_group.web_sg.id
    cidr_blocks       = [var.ip_all]
}
/******** web efs ********/
resource "aws_security_group" "web_efs_sg" {
    name        = "web-efs-sg"
    description = "sg for web-efs"
    vpc_id      = aws_vpc.vpc_1.id
    lifecycle {
        create_before_destroy = true
    }
    depends_on = [ 
        aws_instance.web_private
    ]
    tags = {
        Name = "web-efs-sg"
    }
}
resource "aws_security_group_rule" "web_efs_ingr_from_web" {
    type                     = "ingress"
    from_port                = var.efs_port
    to_port                  = var.efs_port
    protocol                 = "tcp"
    security_group_id        = aws_security_group.web_efs_sg.id
    source_security_group_id = aws_security_group.web_sg.id
}
resource "aws_security_group_rule" "web_efs_out_all" {
    type              = "egress"
    to_port           = 0
    protocol          = "-1"
    from_port         = 0
    security_group_id = aws_security_group.web_efs_sg.id
    cidr_blocks       = ["0.0.0.0/0"]
}
/******** internal loadbalancer ********/
resource "aws_security_group" "inter_lb_sg" {
    name        = "inter-lb-sg"
    description = "sg for internal loadbalancer"
    vpc_id      = aws_vpc.vpc_1.id
    lifecycle { 
        create_before_destroy = true
    }
    depends_on = [
        aws_subnet.web_private
    ]
    tags = {
        Name = "inter-lb-sg" 
    }
}
resource "aws_security_group_rule" "ingr_from_web_private" {
    type              = "ingress"
    to_port           = 5000
    protocol          = "tcp"
    from_port         = 5000
    security_group_id = aws_security_group.inter_lb_sg.id
    source_security_group_id = aws_security_group.web_sg.id
}
resource "aws_security_group_rule" "ingr_http_from_public" {
    type              = "ingress"
    to_port           = 80
    protocol          = "tcp"
    from_port         = 80
    security_group_id = aws_security_group.inter_lb_sg.id
    source_security_group_id = aws_security_group.public_sg.id
}
resource "aws_security_group_rule" "inter-out-all" {
    type              = "egress"
    from_port         = 0
    to_port           = 0
    protocol          = "-1"
    security_group_id = aws_security_group.inter_lb_sg.id
    cidr_blocks       = [var.ip_all]
}
/******** was instance ********/
resource "aws_security_group" "was_sg" {
    name        = "was-sg"
    description = "sg for was instance"
    vpc_id      = aws_vpc.vpc_1.id
    lifecycle { 
        create_before_destroy = true
    }
    depends_on = [
        aws_subnet.was_private
    ]
    tags = {
        Name = "was-sg" 
    }
}
#### internal-lb -> (5000 was)
resource "aws_security_group_rule" "ingr_from_inter_lb" {
    type              = "ingress"
    to_port           = 5000
    protocol          = "tcp"
    from_port         = 5000
    security_group_id = aws_security_group.was_sg.id
    source_security_group_id = aws_security_group.inter_lb_sg.id
}
####
resource "aws_security_group_rule" "ingr_ssh_for_was_with_public" {
    type              = "ingress"
    to_port           = var.ssh_port
    protocol          = "tcp"
    from_port         = var.ssh_port
    security_group_id = aws_security_group.was_sg.id
    source_security_group_id = aws_security_group.public_sg.id
}
resource "aws_security_group_rule" "was_egr_to_was_efs" {
    type                     = "egress" 
    from_port                = var.efs_port
    to_port                  = var.efs_port
    protocol                 = "tcp"
    security_group_id        = aws_security_group.was_sg.id
    source_security_group_id = aws_security_group.was_efs_sg.id
}
resource "aws_security_group_rule" "was-out-all" {
    type              = "egress"
    from_port         = 0
    to_port           = 0
    protocol          = "-1"
    security_group_id = aws_security_group.was_sg.id
    cidr_blocks       = [var.ip_all]
}
/******** was_efs ********/
resource "aws_security_group" "was_efs_sg" {
    name        = "was-efs-sg"
    description = "sg for was-efs"
    vpc_id      = aws_vpc.vpc_1.id
    lifecycle {
        create_before_destroy = true
    }
    depends_on = [ 
        aws_instance.was_private
    ]
    tags = {
        Name = "was-efs-sg"
    }
}
resource "aws_security_group_rule" "was_efs_ingr_from_was" {
    type                     = "ingress"
    from_port                = var.efs_port
    to_port                  = var.efs_port
    protocol                 = "tcp"
    security_group_id        = aws_security_group.was_efs_sg.id
    source_security_group_id = aws_security_group.was_sg.id
}
resource "aws_security_group_rule" "was_efs_out_all" {
    type              = "egress"
    to_port           = 0
    protocol          = "-1"
    from_port         = 0
    security_group_id = aws_security_group.was_efs_sg.id
    cidr_blocks       = ["0.0.0.0/0"]
}