terraform {
  required_version = "1.7.5"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.3"
    }
  }
}
provider "aws" {
  shared_config_files      = ["$HOME/.aws/config"]
  shared_credentials_files = ["$HOME/.aws/credentials"]
}
resource "aws_key_pair" "key_1" {
  key_name   = "terra-key"
  public_key = file("./terra-key.pub")
  tags = {
    Name = "terra-key"
  }
}