resource "aws_internet_gateway" "igw_main" {
  vpc_id = aws_vpc.main_vpc.id

  tags = {
    Name = "igw-main"
  }
}
