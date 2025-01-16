# -----------------------------------------------------------------------------------
# Terraform Configuration File
#
# Purpose   : Terraform Remote State with terraform.tfstate located in s3 for sharing with stakeholders.
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

terraform {
  backend "s3" {
    bucket = "NAME-OF-YOUR-S3-BUCKET" // Name of previously created s3 bucket for data storing
    key = "dev/servers/terraform.tfstate" // Desired path and file name
    region = "us-east-1" // Name of region where s3 is located
  }
}

//======================================================================================================================

data "terraform_remote_state" "network" {
  backend = "s3"
  config = {
    bucket = "NAME-OF-YOUR-S3-BUCKET"
    key = "dev/network/terraform.tfstate"
    region = "us-east-1"
  }
}

data "aws_ami" "latest_amazon_linux" {
  owners = ["amazon"]
  most_recent = true
  filter {
    name   = "name"
    values = ["al2023-ami-*"]
  }
}

//======================================================================================================================

resource "aws_instance" "web_server" {
  ami           = data.aws_ami.latest_amazon_linux.id
  instance_type = "t2.micro"
  vpc_security_group_ids = [aws_security_group.webserver_sg.id]
  subnet_id = data.terraform_remote_state.network.outputs.public_subnet_id[0]
  tags = {
    Name = "WebServer"
  }
}

resource "aws_security_group" "webserver_sg" {
  name = "WebServer Security Group"

  vpc_id = data.terraform_remote_state.network.outputs.vpc_id

  ingress {
    from_port = 80
    to_port = 80
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port = 22
    to_port = 22
    protocol = "tcp"
    cidr_blocks = [data.terraform_remote_state.network.outputs.vpc_cidr]
  }

  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "web-server-sg"
    Owner = "Stan Serbin"
  }
}