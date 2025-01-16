# -----------------------------------------------------------------------------------
# Terraform Configuration File
#
# Purpose   : Conditions and Lookups.
# Author    : StanOps Team
# Created   : 2025-01-14
# Last Edit : 2025-01-14
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

resource "aws_instance" "my_webserver_1" {
  ami = "ami-05576a079321f21f8"
  #  instance_type = var.env == "prod" ? "t2.large" : "t2.micro" // X == CONDITION ? VALUE_IF_TRUE : VALUE_IF_FALSE
  instance_type = var.env == "prod" ? var.ec2_size["prod"] : var.ec2_size["dev"]

  tags = {
    Name  = "${var.env}-server"
    Owner = var.env == "prod" ? var.prod_owner : var.no_prod_owner
  }
}

//======================================================================================================================

resource "aws_instance" "my_dev_server" {
  count         = var.env == "dev" ? 1 : 0
  ami           = "ami-09115b7bffbe3c5e4"
  instance_type = "t2.micro"

  tags = {
    Name = "Dev-server"
  }
}

//======================================================================================================================

resource "aws_instance" "my_webserver_2" {
  ami           = "ami-05576a079321f21f8"
  instance_type = lookup(var.ec2_size, var.env) // X = lookup(map, key)

  tags = {
    Name  = "${var.env}-server"
    Owner = var.env == "prod" ? var.prod_owner : var.no_prod_owner
  }
}

//======================================================================================================================

resource "aws_security_group" "my_terraform_security_group" {
  name        = "Terraform WebServer Dynamic Security Group"
  description = "Dynamic Security Group with SSH, HTTP, and HTTPS rules by Terraform"

  dynamic "ingress" {
    for_each = lookup(var.allow_port_list, var.env)
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

  tags = {
    Name  = "Dynamic Security Group"
    Owner = "Stan Serbin"
  }
}