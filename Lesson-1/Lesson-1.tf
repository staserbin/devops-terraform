# -----------------------------------------------------------------------------------
# Terraform Configuration File
#
# Purpose   : Creating an EC2 instance.
# Author    : StanOps Team
# Created   : 2025-01-06
# Last Edit : 2025-01-06
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

resource "aws_instance" "my_Amazon_Linux" {
  ami           = "ami-01816d07b1128cd2d"
  instance_type = "t2.micro"
  key_name      = "my-instance-key-aws" # Use the existing key pair

  vpc_security_group_ids = [var.security_group_id]

  root_block_device {
    volume_type           = "gp2" # Specify gp2 (General Purpose SSD)
    volume_size           = 8     # 8 GiB storage
    delete_on_termination = true  # Optional: Automatically delete the volume when the instance is terminated
  }

  tags = {
    Name        = "My Amazon Linux Server"
    Description = "Test EC2 with Amazon Linux by Terraform for Lesson-2"
    Owner       = "Stan Serbin"
  }
}