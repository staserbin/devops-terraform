variable "env" {
  default = "prod"
}

variable "prod_owner" {
  default = "Stan Serbin"
}

variable "no_prod_owner" {
  default = "Test User"
}

variable "ec2_size" {
  default = {
    "prod"    = "t2.medium"
    "dev"     = "t3.micro"
    "staging" = "t2.small"
  }
}

variable "allow_port_list" {
  default = {
    "prod" = ["80", "443"]
    "dev"  = ["80", "443", "8080", "22"]
  }
}