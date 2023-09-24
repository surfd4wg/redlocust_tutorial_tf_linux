terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

# Configure the AWS Provider
provider "aws" {
  region = "us-east-1"
}

locals {
  user_data = <<EOF
#!/bin/bash
sudo apt update
sudo apt install nginx
sudo systemctl start nginx
EOF
}

resource "aws_instance" "app_server" {
  ami           = "ami-0db6c6238a40c0681"
  instance_type = "t2.micro"

  user_data_base64 = base64encode(local.user_data)

  key_name = aws_key_pair.terraform_pub_key.key_name
  tags = {
    Name = var.instance_name
  }
}

resource "aws_key_pair" "terraform_pub_key" {
  public_key = file("~/.ssh/<public key name>.pub")
}

variable "instance_name" {
  description = "Value of the Name tag for the EC2 instance"
  type        = string
  default     = "ExampleAppServerInstance"
}

output "instance_id" {
  description = "ID of the EC2 instance"
  value       = aws_instance.app_server.id
}

output "instance_public_ip" {
  description = "Public IP address of the EC2 instance"
  value       = aws_instance.app_server.public_ip
}
