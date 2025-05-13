provider "aws" {
  region = var.region
}

resource "aws_instance" "devops_vm" {
  ami                         = var.ami_id
  instance_type               = var.instance_type
  key_name                    = var.key_name
  vpc_security_group_ids      = [var.security_group_id]
  availability_zone           = var.availability_zone
  associate_public_ip_address = true

  tags = {
    Name = "devops-task"
  }
}
