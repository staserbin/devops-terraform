output "vpc_id" {
  value = aws_vpc.main_vpc.id
}

output "vpc_cidr" {
  value = aws_vpc.main_vpc.cidr_block
}

output "public_subnet_id" {
  value = aws_subnet.public_subnet[*].id
}