
resource "aws_vpc" "main_vpc" {
  cidr_block = "10.0.0.0/16"
  tags = {
    Name = "main_vpc"
  }
  enable_dns_hostnames = true
  enable_dns_support   = true
}
