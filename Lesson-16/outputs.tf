output "rds_password" {
  value       = random_string.rds_password.result
  description = "This is the password from the generator"
}

output "rds_password_from_ssm" {
  value       = data.aws_ssm_parameter.rds_password_from_ssm.value
  description = "This is the password from the AWS SSM Parameter"
}