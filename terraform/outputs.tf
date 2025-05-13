output "public_ip" {
  value = aws_instance.devops_vm.public_ip
}

output "public_dns" {
  value = aws_instance.devops_vm.public_dns
}
