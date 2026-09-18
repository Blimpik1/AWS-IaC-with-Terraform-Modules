resource "aws_vpc" "this" {
  cidr_block           = var.vpc_cidr
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {
    Name      = var.vpc_name
    Terraform = "true"
    Project   = var.project_id
  }
}

resource "aws_internet_gateway" "this" {
  vpc_id = aws_vpc.this.id

  tags = {
    Name      = var.igw_name
    Terraform = "true"
    Project   = var.project_id
  }
}

resource "aws_subnet" "public" {
  for_each = var.public_subnets

  vpc_id                  = aws_vpc.this.id
  cidr_block              = each.value.cidr_block
  availability_zone       = each.value.availability_zone
  map_public_ip_on_launch = true

  tags = {
    Name      = each.value.name
    Terraform = "true"
    Project   = var.project_id
  }
}

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.this.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.this.id
  }

  tags = {
    Name      = var.route_table_name
    Terraform = "true"
    Project   = var.project_id
  }
}

resource "aws_route_table_association" "public" {
  for_each = aws_subnet.public

  subnet_id      = each.value.id
  route_table_id = aws_route_table.public.id
}