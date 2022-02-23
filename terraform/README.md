# Infrastructure as code with terraform
## what is Terraform
### Terraform Architecture
#### Terraform default file/folder structure
##### . gitignore
###### AWS keys with Terraform security

![terraform_with_ansible-new](https://user-images.githubusercontent.com/39882040/155309987-b249b4ee-7d22-4273-8a48-c12cb68ae8c3.jpg)

- Terraform commands:
- `terraform init` To initialise terraform
- `terraform plan` checks the script
- `terraform apply` implement the script
- `terraform destroy` to delete everything

Terraform file/folder structure
- `.tf` extension is used by terraform - `main.tf` is the runner file
- Apply `DRY` (Do not repeat yourself)

### Set up AWS keys as an ENV in windows machine
- `AWS_ACCESS_KEY_ID` for aws access keys
- `AWS_SECRET_ACCESS_KEY` for aws secret keys 
- `click windows key` - `type env` - `edit the system env variable`
- clcik `new` for user variable
- add 2 env variables
- Make sure you restart the terminal in order for the env variables to register. If you don't, it will give you an error that the access and secret keys aren't available.

Initially there is no associated key pair so you can't ssh into the instance. So you can create a key pair and link it into the code, put in under the resources part as shown below.
```
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
```
## Creation of a VPC automatically 
We needed:
- Region - EU-west-1
- CIDR-Block
- Tag

There was some useful documentation on https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/default_route_table. This had information on all the relevant security aspects we had to implement on the terraform document.
```
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
```
Blockers today:
- By mistake I deleted my controller instance and I didn't have an AMI. So I had to remake it and complete the terraform script.