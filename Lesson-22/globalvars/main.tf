# -----------------------------------------------------------------------------------
# Terraform Configuration File
#
# Global Variables in Remote State on S3
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


terraform {
  backend "s3" {
    bucket = "stan-project-variables-remote-state" // set the name of existing S3 bucket
    key    = "globalvars/terraform.tfstate"        // file will be created in specified folder/path
    region = "us-east-1"
  }
}

//======================================================================================================================

output "company_name" {
  value = "StanOps International"
}

output "owner" {
  value = "Stan Serbin"
}

output "tags" {
  value = {
    Project = "Phenix-2025"
    Country = "USA"
  }
}