variable "region" {
  default = "us-east-2"
}

variable "ami_id" {
  default = "ami-0b8b44ec9a8f90422"  # Ubuntu 22.04 LTS (for us-east-2)
}

variable "instance_type" {
  default = "t2.micro"
}

variable "key_name" {
  description = "EC2 key pair name"
}

variable "security_group_id" {
  description = "ID of the existing security group"
}

variable "availability_zone" {
  default = "us-east-2a"
}
