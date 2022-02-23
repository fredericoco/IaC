# Terraform init -will download any required packages
resource "aws_vpc" "terraform_vpc_code_test" {
  cidr_block = "10.0.0.0/16"
  instance_tenancy = "default"

  tags = {
    Name = "eng103a_fred_terraform_vpc_code_test"
  }
  
}

# provider aws
provider "aws" {
  region = "eu-west-1"
  }
# init with terraform `terraform init`
# what do we want to lauch
# Automate the process of creating EC2 instance

# name of the resource
#resource "aws_instance" "fred_tf_app" {
  # which AMI to use
#  ami = var.app_ami_id
# What type of instance
#  instance_type = var.instance_type
#Name the key pair
#  key_name = var.key_name
# do you want public IP
#  associate_public_ip_address = var.associate_public_ip_address
# What is the name of your instance
#  tags = var.tags
#}

