provider "aws" {
    region = "us-east-1"
}

data "template_file" "user_data" {
  template = file("${path.module}/templates/tomcat.tpl")
}

# Resource
resource "aws_instance" "tomcat" {
  ami           = var.ami
  instance_type = var.instance_type
  key_name      = "docker-keys"
  user_data = data.template_file.user_data.rendered 
  vpc_security_group_ids = ["sg-03815f815de9abee5"]
  tags = {
    Name      = "tomcat"
    CreatedBy = "IaC - Terraform"
  }
}
# Outputs 
output "instance_id" {
  value = aws_instance.webserver.*.id
}
