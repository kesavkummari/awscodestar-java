# Terraform AWS Provider Versions
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.0"
    }
  }
}

# Resource
resource "aws_instance" "webserver" {
  ami           = var.ami
  instance_type = var.instance_type

  tags = {
    Name      = "Web Server"
    CreatedBy = "IaC - Terraform"
  }
}
# Outputs 
output "instance_id" {
  value = aws_instance.webserver.*.id
}
