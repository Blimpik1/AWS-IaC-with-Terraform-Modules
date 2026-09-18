variable "vpc_id" {
  description = "VPC ID for target group"
  type        = string
}

variable "subnet_ids" {
  description = "Subnet IDs for ALB and ASG"
  type        = list(string)
}

variable "alb_security_group_id" {
  description = "Security group ID for ALB"
  type        = string
}

variable "instance_security_group_ids" {
  description = "Security group IDs for Launch Template instances"
  type        = list(string)
}

variable "instance_type" {
  description = "EC2 instance type"
  type        = string
}

variable "launch_template_name" {
  description = "Name of the Launch Template"
  type        = string
}

variable "asg_name" {
  description = "Name of the Auto Scaling Group"
  type        = string
}

variable "alb_name" {
  description = "Name of the Application Load Balancer"
  type        = string
}

variable "project_id" {
  description = "Project ID for naming and tagging"
  type        = string
}