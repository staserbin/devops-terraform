# -----------------------------------------------------------------------------------
# Terraform Configuration File
#
# Using Global Variables in Remote State on S3
#
# Author    : StanOps Team
# Created   : 2025-01-19
# Last Edit : 2025-01-19
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


// Receive global variables from S3 with configurations
data "terraform_remote_state" "global" {
  backend = "s3"
  config = {
    bucket = "stan-project-variables-remote-state"
    key    = "globalvars/terraform.tfstate"
    region = "us-east-1"
  }
}

//======================================================================================================================


// Create local variables
locals {
  company_name = data.terraform_remote_state.global.outputs.company_name
  owner        = data.terraform_remote_state.global.outputs.owner
  common_tags  = data.terraform_remote_state.global.outputs.tags
}

//======================================================================================================================


resource "aws_vpc" "vpc_1" {
  cidr_block = "10.0.0.0/16"
  tags = {
    Name    = "Stack1-VPC1"
    Company = local.company_name
    Owner   = local.owner
  }
}

resource "aws_vpc" "vpc_2" {
  cidr_block = "10.0.0.0/16"
  tags       = merge(local.common_tags, { Name = "Stack1-VPC3" })
}