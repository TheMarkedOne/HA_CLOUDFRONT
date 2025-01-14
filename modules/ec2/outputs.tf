output "instance_ids" {
  value = aws_instance.web_server[*].id
}

output "public_ips" {
  value = aws_instance.web_server[*].public_ip
}

output "private_ips" {
  value = aws_instance.web_server[*].private_ip
}

output "elastic_ip_allocation_id" {
  value = aws_eip.vip.id
}

output "elastic_ip_public_ip" {
  value = aws_eip.vip.public_ip
}