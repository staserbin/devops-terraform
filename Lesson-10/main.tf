# -----------------------------------------------------------------------------------
# Terraform Configuration File
#
# Purpose   : Provision Highly Available Web in any Region Default VPC.
# Create:
#     - Security Group for Web Server
#     - Launch Templates with Auto AMI Lookup
#     - Auto Scaling Group using 2 Availability Zones
#     - Classic Load Balancer in 2 Availability Zones
# Author    : StanOps Team
# Created   : 2025-01-11
# Last Edit : 2025-01-11
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

resource "aws_security_group" "web_security_group" {
  name = "Terraform WebServer Dynamic Security Group"
  description = "Dynamic Security Group with SSH, HTTP, and HTTPS rules by Terraform"

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
    Name        = "Dynamic Security Group"
    Owner       = "Stan Serbin"
  }
}

//======================================================================================================================

resource "aws_launch_template" "web_launch_template" {
#   name = "WebServer-Highly-Available-LC"
  name_prefix = "WebServer-Highly-Available-LC-" // Amazon will add random numbers to the end of the string
  image_id      = data.aws_ami.latest_amazon_linux.id
  instance_type = "t2.micro"

  network_interfaces {
    security_groups = [aws_security_group.web_security_group.id]
    associate_public_ip_address = true
  }

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
  name = "ASG-${aws_launch_template.web_launch_template.name}"

  launch_template {
    id = aws_launch_template.web_launch_template.id
    version = "$Latest" // Use the latest version of the Launch Template
  }

  max_size = 2
  min_size = 2
  desired_capacity = 2 // Ensures at least 2 servers are always running
  min_elb_capacity = 2 // At least 2 servers must pass the health check
  health_check_type = "ELB" // Instances failing ELB health checks are replaced

  vpc_zone_identifier = [
    aws_default_subnet.web_default_az1.id,
    aws_default_subnet.web_default_az2.id
  ]

  load_balancers = [aws_elb.web_elb.name]

  dynamic "tag" {
    for_each = {
      Name = "WebServer-in-ASG"
      Owner = "Stan Serbin"
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

resource "aws_elb" "web_elb" {
  name = "WebServer-Highly-Available-ELB"

  availability_zones = [
    data.aws_availability_zones.available_zones.names[0],
    data.aws_availability_zones.available_zones.names[1]
  ]

  security_groups = [aws_security_group.web_security_group.id]

  listener {
    instance_port     = 80
    instance_protocol = "http"
    lb_port           = 80
    lb_protocol       = "http"
  }

  health_check {
    healthy_threshold   = 2
    interval            = 10         // each 10 seconds
    target              = "HTTP:80/" // the first page that will respond to a ping for a health check
    timeout             = 3
    unhealthy_threshold = 2
  }

  tags = {
    Name = "WebServer-Highly-Available-ELB"
    Owner = "Stan Serbin"
  }
}

//======================================================================================================================

resource "aws_default_subnet" "web_default_az1" {
  availability_zone = data.aws_availability_zones.available_zones.names[0]
}

resource "aws_default_subnet" "web_default_az2" {
  availability_zone = data.aws_availability_zones.available_zones.names[1]
}

//======================================================================================================================

output "web_loadbalancer_url" {
  value = aws_elb.web_elb.dns_name
}