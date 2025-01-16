# -----------------------------------------------------------------------------------
# Terraform Configuration File
#
# Purpose   : Password generation.
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

resource "random_string" "rds_password" {
  length           = 12       // length of password
  special          = true     // include special characters
  override_special = "!#$@&%" // special characters that can be used for the password generation
}

//======================================================================================================================

resource "aws_ssm_parameter" "rds_password" {
  name        = "/prod/mysql"
  description = "Master password for RDS MySQL"
  type        = "SecureString"
  value       = random_string.rds_password.result
}

//======================================================================================================================

# Get data (read data) from aws_ssm_parameter fro output, etc.
data "aws_ssm_parameter" "rds_password_from_ssm" {
  name = "/prod/mysql" // specify the name of parameter you want to get/read (name from the line 12)

  depends_on = [aws_ssm_parameter.rds_password] // get it only after password creation
}

//======================================================================================================================

resource "aws_db_instance" "my_rds" {
  identifier           = "prod-rds"
  allocated_storage    = 10
  db_name              = "prod-db"
  engine               = "mysql"
  engine_version       = "8.0"
  instance_class       = "db.t2.micro"
  username             = "administrator"
  password             = data.aws_ssm_parameter.rds_password_from_ssm.value
  parameter_group_name = "default.mysql8.0"
  skip_final_snapshot  = true // when DB will be killed do not do any snapshots, kill in the moment
  apply_immediately    = true // apply all changes immediately to the DB
}