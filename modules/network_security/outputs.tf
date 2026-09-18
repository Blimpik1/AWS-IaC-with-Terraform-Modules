output "ssh_sg_id" {
  description = "ID of the SSH security group"
  value       = aws_security_group.ssh.id
}

output "public_http_sg_id" {
  description = "ID of the public HTTP (ALB) security group"
  value       = aws_security_group.public_http.id
}

output "private_http_sg_id" {
  description = "ID of the private HTTP (EC2) security group"
  value       = aws_security_group.private_http.id
}