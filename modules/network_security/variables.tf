variable "vpc_id" {
  description = "VPC ID where security groups will be created"
  type        = string
}

variable "allowed_ip_range" {
  description = "Allowed CIDR IP blocks for SSH and ALB HTTP access"
  type        = list(string)
}

variable "ssh_sg_name" {
  description = "Name for SSH security group"
  type        = string
}

variable "public_http_sg_name" {
  description = "Name for Public HTTP security group (ALB)"
  type        = string
}

variable "private_http_sg_name" {
  description = "Name for Private HTTP security group (EC2)"
  type        = string
}

variable "project_id" {
  description = "Project ID for tagging"
  type        = string
}