# Terraform init -will download any required packages
resource "aws_vpc" "terraform_vpc_code_test" {
  cidr_block = "10.0.0.0/16"
  instance_tenancy = "default"

  tags = {
    Name = "eng103a_fred_terraform_vpc_code_test"
  }
  
}
resource "aws_subnet" "terraform_subnet" {
  vpc_id = aws_vpc.terraform_vpc_code_test.id
  cidr_block = "10.0.1.0/24"

  tags = {
    Name = "eng103a_fred_subnet"
  }
}
# provider aws
provider "aws" {
  region = "eu-west-1"
  }

resource "aws_security_group" "fred_security_group" {
  name        = "security_group_terraform_fred"
  description = "Security group for terraform fred"
  vpc_id      = aws_vpc.terraform_vpc_code_test.id

  ingress {
    from_port        = "80"
    to_port          = "80"
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]

  }
  ingress {
    from_port        = "22"
    to_port          = "22"
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]

  }
  ingress {
    from_port        = "3000"
    to_port          = "3000"
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]

  }
  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }
}
resource "aws_internet_gateway" "fred_gateway" {
  vpc_id = aws_vpc.terraform_vpc_code_test.id

  tags = {
    Name = "main"
  }
}
resource "aws_route_table" "fred_rt" {
  vpc_id = aws_vpc.terraform_vpc_code_test.id
  
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.fred_gateway.id
    }
}
resource "aws_route_table_association" "fred_tf_rt_association" {
    subnet_id = aws_subnet.terraform_subnet.id
    route_table_id = aws_route_table.fred_rt.id
    }
# init with terraform `terraform init`
# what do we want to lauch
# Automate the process of creating EC2 instance

# name of the resource
resource "aws_instance" "fred_tf_app" {
  # which AMI to use
 ami = var.app_ami_id
# What type of instance
 instance_type = var.instance_type
#Name the key pair
 key_name = var.key_name
# do you want public IP
 associate_public_ip_address = var.associate_public_ip_address
# What is the name of your instance
 tags = var.tags

 vpc_security_group_ids = [aws_security_group.fred_security_group.id]

 subnet_id = aws_subnet.terraform_subnet.id
}

