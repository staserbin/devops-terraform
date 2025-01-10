# -----------------------------------------------------------------------------------
# Terraform Configuration File
#
# Purpose   : Receive data using Data Source.
# Author    : StanOps Team
# Created   : 2025-01-09
# Last Edit : 2025-01-09
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

resource "aws_vpc" "my-vpc-01" {
  cidr_block       = "10.0.0.0/16"
  instance_tenancy = "default"

  tags = {
    Name = "my-vpc-01"
  }
}

//======================================================================================================================

data "aws_availability_zones" "available_zones" {}
data "aws_caller_identity" "caller_id" {}
data "aws_region" "current_region" {}
data "aws_vpcs" "my_vpcs" {}
data "aws_vpc" "my_vpc" {
  tags = {
    Name = "my-vpc-01"
  }

  depends_on = [aws_vpc.my-vpc-01]
}

//======================================================================================================================

resource "aws_subnet" "prod_subnet" {
  vpc_id = data.aws_vpc.my_vpc.id
  availability_zone = data.aws_availability_zones.available_zones.names[0]
  cidr_block = "10.0.0.0/16"
  tags = {
    Name = "Subnet-1 in ${data.aws_availability_zones.available_zones.names[0]}"
    Account = "Subnet in Account ${data.aws_caller_identity.caller_id.account_id}"
    Region = data.aws_region.current_region.description
  }

  depends_on = [data.aws_vpc.my_vpc]
}