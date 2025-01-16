output "web_server_instance_id" {
  value       = aws_instance.my_server_web.id
  description = "This is Web Server id"
}

output "db_server_instance_id" {
  value       = aws_instance.my_server_db.id
  description = "This is DB Server id"
}

output "webserver_sg_id" {
  value       = aws_security_group.my_terraform_security_group.id
  description = "This is Security Group id"
}

output "webserver_sg_arn" {
  value       = aws_security_group.my_terraform_security_group.arn
  description = "This is security group Amazon Resource Name"
}