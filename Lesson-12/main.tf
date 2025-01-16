# -----------------------------------------------------------------------------------
# Terraform Configuration File
#
# Purpose   : Variables in use.
# Author    : StanOps Team
# Created   : 2025-01-13
# Last Edit : 2025-01-13
#
# Requirements:
#   - Terraform v1.4.0 or higher
#   - AWS Provider v5.0.0 or higher
#
# Notes:
#   - Ensure AWS credentials are configured before applying.
# -----------------------------------------------------------------------------------

provider "aws" {
  region     = var.region
  access_key = var.aws_access_key
  secret_key = var.aws_secret_key
}

//======================================================================================================================

data "aws_ami" "latest_amazon_linux" {
  owners      = ["amazon"]
  most_recent = true
  filter {
    name   = "name"
    values = ["al2023-ami-*-kernel-*-x86_64"] // AWS updates AMI name with the latest version (hide versions with '*')
  }
}

//======================================================================================================================

resource "aws_eip" "my_static_ip" {
  instance = aws_instance.my_webserver_linux.id

  tags = merge(var.common_tags, { Name = "Server IP by Terraform" })
}

//======================================================================================================================

resource "aws_instance" "my_webserver_linux" {
  ami           = data.aws_ami.latest_amazon_linux.id // EC2 instance will be run with the latest AMI version
  instance_type = var.instance_type
  key_name      = "my-instance-key-aws" # Use the existing key pair

  root_block_device {
    volume_type           = "gp2" # Specify gp2 (General Purpose SSD)
    volume_size           = 8     # 8 GiB storage
    delete_on_termination = true  # Optional: Automatically delete the volume when the instance is terminated
  }

  tags = merge(var.common_tags, { Name = "Server Build by Terraform" })
}

//======================================================================================================================

resource "aws_security_group" "web_security_group" {
  name        = "Terraform WebServer Dynamic Security Group"
  description = "Dynamic Security Group with SSH, HTTP, and HTTPS rules by Terraform"

  dynamic "ingress" {
    for_each = var.allow_ports
    content {
      from_port   = ingress.value
      to_port     = ingress.value
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
    }
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(var.common_tags, { Name = "Server Security Group Build by Terraform" })
}