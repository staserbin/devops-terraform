# -----------------------------------------------------------------------------------
# Terraform Configuration File
#
# Purpose   : Creating Security Group using dynamic code blocks.
# Author    : StanOps Team
# Created   : 2025-01-08
# Last Edit : 2025-01-08
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

resource "aws_instance" "my_webserver" {
  ami           = "ami-01816d07b1128cd2d"
  instance_type = "t2.micro"
  key_name      = "my-instance-key-aws" # Use the existing key pair

  vpc_security_group_ids = [aws_security_group.my_terraform_security_group.id]

  user_data = file("user_data.sh")

  root_block_device {
    volume_type           = "gp2" # Specify gp2 (General Purpose SSD)
    volume_size           = 8     # 8 GiB storage
    delete_on_termination = true  # Optional: Automatically delete the volume when the instance is terminated
  }

  tags = {
    Name        = "Amazon Linux Server"
    Description = "Test EC2 with Amazon Linux by Terraform for Lesson-2"
    Owner       = "Stan Serbin"
  }
}

resource "aws_security_group" "my_terraform_security_group" {
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