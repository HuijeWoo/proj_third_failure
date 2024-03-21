resource "aws_internet_gateway" "igw_main" {
  vpc_id = aws_vpc.main_vpc.id

  tags = {
    Name = "igw-main"
  }
}

resource "aws_eip" "eip_main" {
  domain = "vpc"

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_nat_gateway" "ngw-main" {
  allocation_id = aws_eip.eip_main.id
  subnet_id     = aws_subnet.public[0].id

  tags = {
    Name = "ngw-main"
  }
}
