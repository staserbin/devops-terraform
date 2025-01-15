output "data_aws_availability_zones" {
  value = data.aws_availability_zones.available_zones.names
}

output "data_aws_caller_identity" {
  value = data.aws_caller_identity.caller_id.account_id
}

output "data_aws_region_description" {
  value = data.aws_region.current_region.description
}