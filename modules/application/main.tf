data "aws_ami" "amazon_linux" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["al2023-ami-2023.*-x86_64"]
  }
}

resource "aws_launch_template" "this" {
  name          = var.launch_template_name
  image_id      = data.aws_ami.amazon_linux.id
  instance_type = var.instance_type

  network_interfaces {
    associate_public_ip_address = true
    delete_on_termination       = true
    security_groups             = var.instance_security_group_ids
  }

  metadata_options {
    http_endpoint = "enabled"
    http_tokens   = "optional"
  }

  user_data = base64encode(<<-EOF
              #!/bin/bash
              mkdir -p /var/www/html

              TOKEN=$(curl -s -S -X PUT "http://169.254.169.254/latest/api/token" -H "X-aws-ec2-metadata-token-ttl-seconds: 21600" || true)
              INSTANCE_ID=$(curl -s -S -H "X-aws-ec2-metadata-token: $TOKEN" http://169.254.169.254/latest/meta-data/instance-id 2>/dev/null || echo "i-unknown")
              PRIVATE_IP=$(curl -s -S -H "X-aws-ec2-metadata-token: $TOKEN" http://169.254.169.254/latest/meta-data/local-ipv4 2>/dev/null || echo "0.0.0.0")
              MY_UUID=$(cat /proc/sys/kernel/random/uuid 2>/dev/null || echo "$INSTANCE_ID")

              cat <<HTML > /var/www/html/index.html
              <!DOCTYPE html>
              <html>
              <head><title>App</title></head>
              <body>
              <h1>Launch template ${var.launch_template_name}</h1>
              <p>UUID: $MY_UUID</p>
              <p>Instance ID: $INSTANCE_ID</p>
              <p>Instance type: ${var.instance_type}</p>
              <p>Private IP: $PRIVATE_IP</p>
              <p>Security groups: ${var.project_id}-ssh-sg and ${var.project_id}-private-http-sg</p>
              <p>Network interface setting: delete_on_termination = true</p>
              </body>
              </html>
              HTML

              # Запускаємо HTTP-сервер миттєво, щоб Health Check пройшов за перші 5 секунд:
              nohup python3 -m http.server 80 --directory /var/www/html > /tmp/py_http.log 2>&1 &

              # Паралельно встановлюємо Apache як повноцінний сервіс:
              dnf install -y httpd || yum install -y httpd || true
              pkill -f "python3 -m http.server" || true
              systemctl enable --now httpd || true
              EOF
  )

  tag_specifications {
    resource_type = "instance"
    tags = {
      Name      = "${var.project_id}-instance"
      Terraform = "true"
      Project   = var.project_id
    }
  }

  tags = {
    Name      = var.launch_template_name
    Terraform = "true"
    Project   = var.project_id
  }
}

resource "aws_lb" "this" {
  name               = var.alb_name
  internal           = false
  load_balancer_type = "application"
  security_groups    = [var.alb_security_group_id]
  subnets            = var.subnet_ids

  tags = {
    Name      = var.alb_name
    Terraform = "true"
    Project   = var.project_id
  }
}

resource "aws_lb_target_group" "this" {
  name     = "${var.project_id}-tg"
  port     = 80
  protocol = "HTTP"
  vpc_id   = var.vpc_id

  health_check {
    path                = "/"
    protocol            = "HTTP"
    port                = "80"
    matcher             = "200"
    interval            = 10
    timeout             = 4
    healthy_threshold   = 2
    unhealthy_threshold = 2
  }

  tags = {
    Name      = "${var.project_id}-tg"
    Terraform = "true"
    Project   = var.project_id
  }
}

resource "aws_lb_listener" "this" {
  load_balancer_arn = aws_lb.this.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.this.arn
  }
}

resource "aws_autoscaling_group" "this" {
  name                      = var.asg_name
  desired_capacity          = 2
  min_size                  = 2
  max_size                  = 2
  vpc_zone_identifier       = var.subnet_ids
  target_group_arns         = [aws_lb_target_group.this.arn]
  health_check_type         = "ELB"
  health_check_grace_period = 120
  wait_for_elb_capacity     = 2

  launch_template {
    id      = aws_launch_template.this.id
    version = "$Latest"
  }

  lifecycle {
    ignore_changes = [load_balancers, target_group_arns]
  }

  tag {
    key                 = "Name"
    value               = var.asg_name
    propagate_at_launch = true
  }

  tag {
    key                 = "Terraform"
    value               = "true"
    propagate_at_launch = true
  }

  tag {
    key                 = "Project"
    value               = var.project_id
    propagate_at_launch = true
  }
}

resource "aws_autoscaling_attachment" "this" {
  autoscaling_group_name = aws_autoscaling_group.this.id
  lb_target_group_arn    = aws_lb_target_group.this.arn
}