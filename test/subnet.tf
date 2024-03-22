
resource "aws_subnet" "public" {
  count = length(var.my_cidr_public)

  vpc_id                  = aws_vpc.main_vpc.id
  cidr_block              = var.my_cidr_public[count.index]
  availability_zone       = var.my_availability_zone[count.index]
  map_public_ip_on_launch = true
  tags = {
    Name = "subnet-public-${count.index + 1}"
    Type = "Public"
  }
}

