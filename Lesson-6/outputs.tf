output "webserver_instance_id" {
  value = aws_instance.my_webserver.id
  description = "This is WebServer id"
}

output "webserver_public_ip" {
  value = aws_eip.my_static_ip.public_ip
  description = "This is AWS Elastic IP public IP"
}

output "webserver_sg_id" {
  value = aws_security_group.my_terraform_security_group.id
  description = "This is Security Group id"
}

output "webserver_sg_arn" {
  value = aws_security_group.my_terraform_security_group.arn
  description = "This is security group Amazon Resource Name"
}