
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

resource "aws_subnet" "web_private" {
  count = length(var.my_cidr_web_private)

  vpc_id            = aws_vpc.main_vpc.id
  cidr_block        = var.my_cidr_web_private[count.index]
  availability_zone = var.my_availability_zone[count.index]
  tags = {
    Name = "subnet-web-private-${count.index + 1}"
    Type = "Private-web"
  }
}

resource "aws_subnet" "was_private" {
  count = length(var.my_cidr_was_private)

  vpc_id            = aws_vpc.main_vpc.id
  cidr_block        = var.my_cidr_was_private[count.index]
  availability_zone = var.my_availability_zone[count.index]
  tags = {
    Name = "subnet-was-private-${count.index + 1}"
    Type = "Private-was"
  }
}
