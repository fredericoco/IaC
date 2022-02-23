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