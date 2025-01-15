# -----------------------------------------------------------------------------------
# Terraform Configuration File
#
# Purpose   : Count, for, if - loops.
# Author    : StanOps Team
# Created   : 2025-01-15
# Last Edit : 2025-01-15
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
}

//======================================================================================================================

variable "aws_users" {
  description = "List of AIM Users to create"
  default = ["Stan", "Alex", "Tim", "Boris"]
}

//======================================================================================================================

resource "aws_iam_user" "user_1" {
  name = "pushkin"
}

//======================================================================================================================

resource "aws_iam_user" "users" {
  count = length(var.aws_users)
  name = element(var.aws_users, count.index)
}

//======================================================================================================================

resource "aws_instance" "servers" {
  count = 3
  ami           = "ami-09115b7bffbe3c5e4"
  instance_type = "t2.micro"
  tags = {
    Name = "Server Number ${count.index + 1}"       // Add 1 because the indexing started at 0
  }
}
