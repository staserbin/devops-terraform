# -----------------------------------------------------------------------------------
# Terraform Configuration File
#
# Purpose   : Auto search of AMI with Data Source.
# Author    : StanOps Team
# Created   : 2025-01-10
# Last Edit : 2025-01-10
#
# Requirements:
#   - Terraform v1.4.0 or higher
#   - AWS Provider v5.0.0 or higher
#
# Notes:
#   - Ensure AWS credentials are configured before applying.
# -----------------------------------------------------------------------------------


provider "aws" {
  region     = "us-east-1"
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

resource "aws_instance" "my_webserver_linux" {
  ami           = data.aws_ami.latest_amazon_linux.id // EC2 instance will be run with the latest AMI version
  instance_type = "t2.micro"
  key_name      = "my-instance-key-aws" # Use the existing key pair

  user_data = file("user_data.sh")

  root_block_device {
    volume_type           = "gp2" # Specify gp2 (General Purpose SSD)
    volume_size           = 8     # 8 GiB storage
    delete_on_termination = true  # Optional: Automatically delete the volume when the instance is terminated
  }
}