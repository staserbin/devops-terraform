# -----------------------------------------------------------------------------------
# Auto Fill parameters for DEV env
#
# Author    : StanOps Team
# Created   : 2025-01-13
# Last Edit : 2025-01-13
#
# Command to run: terraform apply -var-file="dev.tfvars"
# -----------------------------------------------------------------------------------


region        = "us-east-2"
instance_type = "t2.micro"

allow_ports = ["80", "22", "8080"]

common_tags = {
  Owner       = "Stan Serbin"
  Project     = "Snake Inc."
  Environment = "dev"
}