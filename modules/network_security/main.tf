resource "aws_security_group" "ssh" {
  name        = var.ssh_sg_name
  description = "Allow SSH inbound traffic"
  vpc_id      = var.vpc_id

  ingress {
    description = "SSH from allowed IPs"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = var.allowed_ip_range
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name      = var.ssh_sg_name
    Terraform = "true"
    Project   = var.project_id
  }
}

resource "aws_security_group" "public_http" {
  name        = var.public_http_sg_name
  description = "Allow public HTTP traffic to ALB"
  vpc_id      = var.vpc_id

  ingress {
    description = "HTTP from allowed IPs"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = var.allowed_ip_range
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name      = var.public_http_sg_name
    Terraform = "true"
    Project   = var.project_id
  }
}

resource "aws_security_group" "private_http" {
  name        = var.private_http_sg_name
  description = "Allow HTTP traffic from ALB SG to EC2"
  vpc_id      = var.vpc_id

  ingress {
    description     = "HTTP from ALB SG"
    from_port       = 80
    to_port         = 80
    protocol        = "tcp"
    security_groups = [aws_security_group.public_http.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name      = var.private_http_sg_name
    Terraform = "true"
    Project   = var.project_id
  }
}