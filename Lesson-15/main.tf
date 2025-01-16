provider "aws" {
  region = "us_east_1"
}

resource "null_resource" "command1" {
  provisioner "local-exec" {
    command = "echo Terraform START: $(date) >> log.txt"
  }
}

resource "null_resource" "command2" {
  provisioner "local-exec" {
    command = "ping -c 5 www.google.com"
  }
}

resource "null_resource" "command3" {
  provisioner "local-exec" {
    command     = "print('Hello, World!')"
    interpreter = ["python", "-c"]
  }
}

resource "null_resource" "command4" {
  provisioner "local-exec" {
    command = "echo $NAME1 $NAME2 $NAME3 >> name.txt"
    environment = {
      NAME1 = "Alex"
      NAME2 = "Stan"
      NAME3 = "Tim"
    }
  }
}

resource "null_resource" "command6" {
  provisioner "local-exec" {
    command = "echo Terraform END: $(date) >> log.txt"
  }
  depends_on = [
    null_resource.command1,
    null_resource.command2,
    null_resource.command3,
    null_resource.command4
  ]
}