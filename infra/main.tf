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


resource "aws_lb" "cloudbinary" {
  name               = "cloudbinary-lb-tf"
  internal           = false
  load_balancer_type = "application"
  security_groups    = "sg-03815f815de9abee5"
  subnets            = [for subnet in aws_subnet.public : subnet.id]

  enable_deletion_protection = true

  access_logs {
    bucket  = aws_s3_bucket.lb_logs.bucket
    prefix  = "cloudbinary-lb"
    enabled = true
  }

  tags = {
    Environment = "production"
  }
}
