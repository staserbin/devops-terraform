# -----------------------------------------------------------------------------------
# Terraform Configuration File
#
# Purpose   : Local Variables in use.
# Author    : StanOps Team
# Created   : 2025-01-13
# Last Edit : 2025-01-13
#
# Requirements:
#   - Terraform v1.4.0 or higher
#   - AWS Provider v5.0.0 or higher
#
# Notes:
#   - Ensure AWS credentials are configured before applying.
# -----------------------------------------------------------------------------------

provider "aws" {
  region     = var.region
  access_key = var.aws_access_key
  secret_key = var.aws_secret_key
}

//======================================================================================================================

data "aws_region" "current_region" {}
data "aws_availability_zones" "available_zones" {}

//======================================================================================================================

locals {
  full_project_name = "${var.environment}-${var.project_name}"
  project_owner     = "${var.owner} is owner of the ${var.project_name} project"
  country           = "USA"
  az_list           = join(", ", data.aws_availability_zones.available_zones.names)
  region            = data.aws_region.current_region.description
  location          = "In ${local.region} there are AZ: ${local.az_list}"
}

//======================================================================================================================

resource "aws_eip" "my_static_ip" {
  tags = {
    Owner         = var.owner
    Project       = local.full_project_name
    Project_Owner = local.project_owner
    Country       = local.country
    AZ_Regions    = local.az_list
    Location      = local.location
  }
}