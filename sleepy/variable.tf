variable "az_list" {
    type    = list(string)
    default = ["ap-northeast-2a", "ap-northeast-2c"]
}
variable "vpc_cidr_block"{
    type = string
    default = "10.0.0.0/16"
}
variable "cidr_public" {
    type = list(string)
    default = ["10.0.1.0/24", "10.0.2.0/24"]
}
variable "cidr_web" {
    type = list(string)
    default = ["10.0.11.0/24", "10.0.12.0/24"]
}
variable "cidr_was" {
    type = list(string)
    default = ["10.0.21.0/24", "10.0.22.0/24"]
}
variable "ip_all"{
    type = string
    default = "0.0.0.0/0"
}
variable "basic_instance_type"{
    type = list(string)
    default = ["t2.micro", "t2.micro"]
}

# 하느님이 보우하사
variable "efs_mount_point" {
  description = "Determine the mount point"
  type        = string
  default     = "/home/ec2-user/service"
}