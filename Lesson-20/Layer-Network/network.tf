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
    bucket = "NAME-OF-YOUR-S3-BUCKET"        // Name of previously created s3 bucket for data storing
    key    = "dev/network/terraform.tfstate" // Desired path and file name
    region = "us-east-1"                     // Name of region where s3 is located
  }
}

//======================================================================================================================

data "aws_availability_zones" "available_zones" {}

//======================================================================================================================

resource "aws_vpc" "main_vpc" {
  cidr_block = var.vpc_cidr
  tags = {
    Name = "${var.env}-VPC"
  }
}

resource "aws_internet_gateway" "main_gateway" {
  vpc_id = aws_vpc.main_vpc.id
  tags = {
    Name = "${var.env}-IGW"
  }
}

resource "aws_subnet" "public_subnet" {
  count                   = length(var.public_subnet_cidrs)
  vpc_id                  = aws_vpc.main_vpc.id
  cidr_block              = element(var.public_subnet_cidrs, count.index)
  availability_zone       = data.aws_availability_zones.available_zones.names[count.index]
  map_public_ip_on_launch = true
  tags = {
    Name = "${var.env}-public-${count.index + 1}"
  }
}

resource "aws_route_table" "public_subnets" {
  vpc_id = aws_vpc.main_vpc.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.main_gateway.id
  }
  tags = {
    Name = "${var.env}-route-public-subnets"
  }
}

resource "aws_route_table_association" "public_routes" {
  count          = length(aws_subnet.public_subnet[*].id)
  route_table_id = aws_route_table.public_subnets.id
  subnet_id      = element(aws_subnet.public_subnet[*].id, count.index)
}