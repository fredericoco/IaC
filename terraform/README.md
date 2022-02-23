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
