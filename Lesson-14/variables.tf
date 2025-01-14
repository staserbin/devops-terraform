variable "aws_access_key" {
  description = "AWS Access Key ID"
  type        = string
  sensitive   = true
}

variable "aws_secret_key" {
  description = "AWS Secret Access Key"
  type        = string
  sensitive   = true
}

variable "region" {
  description = "AWS Region to deploy server"
  type = string
  default = "us-east-1"
}

variable "environment" {
  type = string
  default = "DEV"
}

variable "project_name" {
  type = string
  default = "STELLA"
}

variable "owner" {
  type = string
  default = "Stan Serbin"
}