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

variable "instance_type" {
  description = "Instance type"
  type = string
  default = "t2.micro"
}

variable "allow_ports" {
  description = "List of ports for server"
  type = list
  default = ["80", "443", "22"]
}

variable "common_tags" {
  description = "Common tags for all resources"
  type = map
  default = {
    Owner = "Stan Serbin"
    Project = "Snake"
  }
}