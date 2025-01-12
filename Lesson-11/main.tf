# -----------------------------------------------------------------------------------
# Terraform Configuration File
#
# Purpose   : Provision Highly Available Web Site using ZeroDowntime + Green/Blue Deployment.
# Create:
#     - 2x Launch Templates
#     - 2x Auto Scaling Group
#     - Application Load Balancer
# Author    : StanOps Team
# Created   : 2025-01-12
# Last Edit : 2025-01-12
#
# Requirements:
#   - Terraform v1.4.0 or higher
#   - AWS Provider v5.0.0 or higher
#
# Notes:
#   - Ensure AWS credentials are configured before applying.
# -----------------------------------------------------------------------------------

provider "aws" {
  region = "us-east-1"
  access_key = var.aws_access_key
  secret_key = var.aws_secret_key

  default_tags {
    tags = {
      Owner       = "Stan Serbin"
      Project     = "ZeroDowntime + Green/Blue Deployment"
      CreatedBy   = "Terraform"
    }
  }
}

//======================================================================================================================

data "aws_availability_zones" "available_zones" {}

data "aws_ami" "latest_amazon_linux" {
  owners = ["amazon"]
  most_recent = true
  filter {
    name   = "name"
    values = ["al2023-ami-*-kernel-*-x86_64"]
  }
}

//======================================================================================================================

resource "aws_default_vpc" "default_vpc" {}

resource "aws_default_subnet" "web_default_az1" {
  availability_zone = data.aws_availability_zones.available_zones.names[0]
}

resource "aws_default_subnet" "web_default_az2" {
  availability_zone = data.aws_availability_zones.available_zones.names[1]
}

//======================================================================================================================

resource "aws_security_group" "web_security_group" {
  name = "Terraform WebServer Dynamic Security Group"
  description = "Dynamic Security Group with SSH, HTTP, and HTTPS rules by Terraform"
  vpc_id = aws_default_vpc.default_vpc.id

  dynamic "ingress" {
    for_each = ["80", "443", "22"]
    content {
      from_port = ingress.value
      to_port = ingress.value
      protocol = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
    }
  }

  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name        = "Web Security Group"
  }
}

//======================================================================================================================

resource "aws_launch_template" "web_launch_template" {
  name = "WebServer-Highly-Available-LT"
  image_id      = data.aws_ami.latest_amazon_linux.id
  instance_type = "t2.micro"

  vpc_security_group_ids = [aws_security_group.web_security_group.id]

  user_data = filebase64("user_data.sh")

  block_device_mappings {
    device_name = "/dev/xvda" // Root volume

    ebs {
      volume_type           = "gp2"       // General Purpose SSD
      volume_size           = 8          // 20 GiB
      delete_on_termination = true        // Delete volume on instance termination
    }
  }

  tag_specifications {
    resource_type = "instance"
    tags = {
      Name = "WebServer Instance"
    }
  }

  lifecycle {
    create_before_destroy = true
  }
}

//======================================================================================================================

resource "aws_autoscaling_group" "web_autoscaling_group" {
  name = "ASG-version-${aws_launch_template.web_launch_template.latest_version}"
  min_size = 2
  max_size = 2
  min_elb_capacity = 2 // At least 2 servers must pass the health check
  health_check_type = "ELB" // Instances failing ELB health checks are replaced

  target_group_arns = [aws_lb_target_group.web_target_group.arn]

  vpc_zone_identifier = [
    aws_default_subnet.web_default_az1.id,
    aws_default_subnet.web_default_az2.id
  ]

  launch_template {
    id = aws_launch_template.web_launch_template.id
    version = aws_launch_template.web_launch_template.latest_version
  }

  dynamic "tag" {
    for_each = {
      Name = "WebServer-in-ASG-${aws_launch_template.web_launch_template.latest_version}"
    }
    content {
      key = tag.key
      value = tag.value
      propagate_at_launch = true
    }
  }

  lifecycle {
    create_before_destroy = true
  }
}

//======================================================================================================================

resource "aws_lb" "web_load_balancer" {
  name = "WebSerer-HighlyAvailable-ALB"
  load_balancer_type = "application"
  security_groups = [aws_security_group.web_security_group.id]
  subnets = [
    aws_default_subnet.web_default_az1.id,
    aws_default_subnet.web_default_az2.id
  ]
}

//======================================================================================================================

resource "aws_lb_target_group" "web_target_group" {
  name = "WebServer-HighlyAvailable-TG"
  vpc_id = aws_default_vpc.default_vpc.id
  port = 80
  protocol = "HTTP"
  deregistration_delay = "10" // 10 seconds
}

//======================================================================================================================

resource "aws_lb_listener" "http_load_balancer_listener" {
  load_balancer_arn = aws_lb.web_load_balancer.arn
  port = "80"
  protocol = "HTTP"

  default_action {
    type = "forward"
    target_group_arn = aws_lb_target_group.web_target_group.arn
  }
}

//======================================================================================================================

output "web_loadbalancer_url" {
  value = aws_lb.web_load_balancer.dns_name
}