# Terraform init -will download any required packages

# provider aws
provider "aws" {
  

# which region
   region = "eu-west-1"
}
# init with terraform `terraform init`
# what do we want to lauch
# Automate the process of creating EC2 instance

# name of the resource
resource "aws_instance" "fred_tf_app" {
  # which AMI to use
  ami = "ami-07d8796a2b0f8d29c"
# What type of instance
  instance_type = "t2.micro"
#Name the key pair
  key_name = "eng103a_fred"
# do you want public IP
  associate_public_ip_address = true
# What is the name of your instance
  tags = {
    Name = "103a_Fred_tf_app"
  }
}
