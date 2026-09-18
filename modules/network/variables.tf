variable "vpc_cidr" {
  description = "CIDR block for the VPC"
  type        = string
}

variable "vpc_name" {
  description = "Name tag for the VPC"
  type        = string
}

variable "public_subnets" {
  description = "Map of public subnets configuration"
  type = map(object({
    cidr_block        = string
    availability_zone = string
    name              = string
  }))
}

variable "igw_name" {
  description = "Name tag for the Internet Gateway"
  type        = string
}

variable "route_table_name" {
  description = "Name tag for the public Route Table"
  type        = string
}

variable "project_id" {
  description = "Project ID for tagging"
  type        = string
}