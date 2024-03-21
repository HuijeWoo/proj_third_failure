
resource "aws_route_table" "route_public" {
  vpc_id = aws_vpc.main_vpc.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw_main.id
  }
  route {
    cidr_block = "10.0.0.0/16"
    gateway_id = "local"
  }
  tags = {
    Name = "route-public"
  }
}

resource "aws_route_table" "route_private" {
  vpc_id = aws_vpc.main_vpc.id
  route {
    cidr_block = "10.0.0.0/16"
    gateway_id = "local"
  }
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_nat_gateway.ngw-main.id
  }
  tags = {
    Name = "route-private"
  }
}
