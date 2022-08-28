/* terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.0"
    }
  }
} */

provider "aws" {
  region = "us-east-1"
  #profile = "default"
}

/* data "template_file" "user_data" {
  template = file("${path.module}/templates/tomcat.tpl")
} */

# Resource
resource "aws_instance" "dev" {
  ami           = var.ami
  instance_type = var.instance_type
  key_name      = "docker-keys"
  #user_data              = data.template_file.user_data.rendered
  vpc_security_group_ids = ["sg-03815f815de9abee5"]
  tags = {
    Name      = "dev"
    CreatedBy = "IaC - Terraform"
  }
}
# Outputs 
output "instance_id" {
  value = aws_instance.dev.*.id
}