resource "aws_key_pair" "terra_key" {
  key_name   = "terra-key"
  public_key = file("./terra-key.pub")
  tags = {
    Name = "terra-key"
  }
}
