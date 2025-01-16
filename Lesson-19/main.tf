# -----------------------------------------------------------------------------------
# Terraform Configuration File
#
# Purpose   : Create resources in several AWS Regions/Account at time
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

  // instead of access_key and secret_key, assume role can be done with specified role from logged in account
  assume_role {
    role_arn = "arn:aws:iam::123456789:role/RemoteAdmins" // arn:aws:iam::IAM_ACCOUNT_ID:role/NAME_OF_PRE_CREATED_ROLE
  }
}


provider "aws" {
  region = "us-east-2"
  alias  = "OHIO"
}


provider "aws" {
  region = "us-west-2"
  alias  = "OREGON"
}

//======================================================================================================================

data "aws_ami" "default_latest_amazon_linux" {
  owners      = ["137112412989"]
  most_recent = true
  filter {
    name   = "name"
    values = ["amazon/images/hvm-ssd/al-ami-*"]
  }
}


data "aws_ami" "ohio_latest_amazon_linux" {
  provider    = aws.OHIO
  owners      = ["137112412989"]
  most_recent = true
  filter {
    name   = "name"
    values = ["al2023-ami-*"]
  }
}


data "aws_ami" "oregon_latest_amazon_linux" {
  provider    = aws.OREGON
  owners      = ["137112412989"]
  most_recent = true
  filter {
    name   = "name"
    values = ["amazon/images/hvm-ssd/al-ami-*"]
  }
}

//======================================================================================================================

resource "aws_instance" "default_server" {
  ami           = data.aws_ami.default_latest_amazon_linux.id
  instance_type = "t2.micro"
  tags = {
    Name = "Default Server"
  }
}


resource "aws_instance" "dev_server" {
  provider      = aws.OHIO
  ami           = data.aws_ami.ohio_latest_amazon_linux.id
  instance_type = "t2.micro"
  tags = {
    Name = "Dev Server in Ohio"
  }
}


resource "aws_instance" "prod_server" {
  provider      = aws.OREGON
  ami           = data.aws_ami.oregon_latest_amazon_linux.id
  instance_type = "t2.micro"
  tags = {
    Name = "Prod Server in Oregon"
  }
}