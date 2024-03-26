resource "aws_vpc" "vpc_1" {
    cidr_block = var.vpc_cidr_block
    tags = {
        Name = "vpc_1"
    }
    enable_dns_hostnames = true
    enable_dns_support = true
}
resource "aws_subnet" "public" {
    count = length(var.cidr_public)
    vpc_id                  = aws_vpc.vpc_1.id
    cidr_block              = var.cidr_public[count.index]
    availability_zone       = var.az_list[count.index]
    map_public_ip_on_launch = true
    tags = {
        Name = "subnet_public-${count.index + 1}"
        Type = "public_subnet"
    }
}
resource "aws_subnet" "web_private" {
    count = length(var.cidr_web)
    vpc_id            = aws_vpc.vpc_1.id
    cidr_block        = var.cidr_web[count.index]
    availability_zone = var.az_list[count.index]
    tags = {
        Name = "subnet_web_private-${count.index + 1}"
        Type = "private_web"
  }
}
resource "aws_subnet" "was_private" {
    count = length(var.cidr_was)
    vpc_id            = aws_vpc.vpc_1.id
    cidr_block        = var.cidr_was[count.index]
    availability_zone = var.az_list[count.index]
    tags = {
        Name = "subnet_was_private-${count.index + 1}"
        Type = "private_was"
  }
}
resource "aws_route_table" "route_public" {
    vpc_id = aws_vpc.vpc_1.id
    route {
        cidr_block = var.ip_all
        gateway_id = aws_internet_gateway.igw_1.id
    }
    route {
        cidr_block = var.vpc_cidr_block
        gateway_id = "local"
    }
    tags = {
        Name = "route-public"
    }
}
resource "aws_route_table" "route_private" {
    vpc_id = aws_vpc.vpc_1.id
    route {
        cidr_block = var.vpc_cidr_block
        gateway_id = "local"
    }
    route {
        cidr_block = var.ip_all
        gateway_id = aws_nat_gateway.ngw_1.id
    }
    tags = {
        Name = "route-private"
    }
}
resource "aws_internet_gateway" "igw_1" {
    vpc_id = aws_vpc.vpc_1.id
    tags = {
        Name = "igw-1"
    }
}
resource "aws_eip" "eip_1" {
  domain = "vpc"
  lifecycle {
    create_before_destroy = true
  }
}
resource "aws_nat_gateway" "ngw_1" {
  allocation_id = aws_eip.eip_1.id
  subnet_id     = aws_subnet.public[0].id
  tags = {
    Name = "ngw-1"
  }
}
resource "aws_route_table_association" "public" {
  count          = length(var.cidr_public)
  subnet_id      = element(aws_subnet.public.*.id, count.index)
  route_table_id = aws_route_table.route_public.id
}
resource "aws_route_table_association" "web_private" {
  count          = length(var.cidr_web)
  subnet_id      = element(aws_subnet.web_private.*.id, count.index)
  route_table_id = aws_route_table.route_private.id
}
resource "aws_route_table_association" "was_private" {
  count          = length(var.cidr_was)
  subnet_id      = element(aws_subnet.was_private.*.id, count.index)
  route_table_id = aws_route_table.route_private.id
}

### endpoint

resource "aws_vpc_endpoint" "s3" {
  vpc_id       = aws_vpc.vpc_1.id
  service_name = "com.amazonaws.${var.az_list[0]}.s3"
  vpc_endpoint_type = "Gateway" # default
  # route table에 자동 등록...
  subnet_ids = [aws_subnet.was_private[*].id, aws_subnet.web_private[*].id]
  route_table_ids = [aws_route_table.route_private.id]
  security_group_ids = [aws_security_group.was_sg,aws_security_group.web_sg]
  tags = {
    Name = "vpc_endpoint_for_s3"
  }
}