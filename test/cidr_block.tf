
variable "my_cidr_public" {
  type    = list(string)
  default = ["10.0.1.0/24", "10.0.2.0/24"]
}

variable "my_cidr_web_private" {
  type    = list(string)
  default = ["10.0.11.0/24", "10.0.22.0/24"]
}

variable "my_cidr_was_private" {
  type    = list(string)
  default = ["10.0.33.0/24", "10.0.44.0/24"]
}

