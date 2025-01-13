output "my_server_ip" {
  value = aws_eip.my_static_ip.public_ip
}

output "my_instance_id" {
  value = aws_instance.my_webserver_linux.id
}

output "my_sg_id" {
  value = aws_security_group.web_security_group.id
}