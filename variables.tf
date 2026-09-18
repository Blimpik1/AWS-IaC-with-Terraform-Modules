variable "aws_region" {
  description = "AWS region for resources"
  type        = string
}

variable "project_id" {
  description = "Project ID identifier"
  type        = string
}

variable "vpc_cidr" {
  description = "VPC CIDR block"
  type        = string
}

variable "allowed_ip_range" {
  description = "Allowed IP ranges for security groups"
  type        = list(string)
}