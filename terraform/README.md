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
- The command `refreshenv` is useful because it refreshes the environment

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
## Creation of a VPC and other security aspects automatically 
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
- Issue with terraform, regarding the protocol, I used the security groups that I had on AWS, which caused an issue because the it did not recognise the protocol.
- Some small issues with the curly brackets.

## Jenkins and Ansible

```
sudo apt remove --purge python3 (edited)
sudo apt remove --purge python3-pip
sudo apt install software-properties-common -y
sudo add-apt-repository ppa:deadsnakes/ppa
sudo apt install python3.9 -y
update-alternatives --install /usr/bin/python python /usr/bin/python3 1
python --version
```

I messed up the key so I couldn't ssh into the instance. Annoyingly I was making progress at this point.

# Creating an autoscaling group, autoload balancer, and cloudwatch using terraform

In order to create the ALB and autoscaler, we need to have a few more pieces of additional architecture. For the load balancer you need to create additional subnets. This is so that if the main subnet setup goes down, the activity can be redirected to another subnet. This can be seen in the code by looking at public subnet 2 and 3.

The general launch configuration has to be set up, this will launch the instance(from an AMI) and userdata can be run so some commands can be executed.

The autosclaing group has all the setting it had on AWS, but setting them up on teraform is straightfoward.

The autoscaling policies need to be set up. One for up and one for down.

The cloudwatch alarm needs to be set up for both situations.

The linux stress command was installed and used to test the autoscaling process.


```
sudo apt-get install stress
sudo stress --cpu  8 --timeout 20000
```

The only blocker on this task was related to destroying the autoscaler and other infrastructure created by terraform. This is due to AWS not allowing you to terminate some of the security groups and VPCs without getting rid of everything else. The order is Autoscaling group -> instances -> VPC -> `terraform destroy`

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
  availability_zone = "eu-west-1b"
}
resource "aws_subnet" "terraform_subnet2" {
  vpc_id = aws_vpc.terraform_vpc_code_test.id
  cidr_block = "10.0.2.0/24"

  tags = {
    Name = "eng103a_fred_subnet2"
  }
  availability_zone = "eu-west-1a"
}
resource "aws_subnet" "terraform_subnet3" {
  vpc_id = aws_vpc.terraform_vpc_code_test.id
  cidr_block = "10.0.3.0/24"

  tags = {
    Name = "eng103a_fred_subnet3"
  }
  availability_zone = "eu-west-1c"
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
#resource "aws_instance" "fred_tf_app" {
  # which AMI to use
# ami = var.app_ami_id
# What type of instance
# instance_type = var.instance_type
#Name the key pair
# key_name = var.key_name
# do you want public IP
# associate_public_ip_address = var.associate_public_ip_address
# What is the name of your instance
# tags = var.tags

# vpc_security_group_ids = [aws_security_group.fred_security_group.id]

# subnet_id = aws_subnet.terraform_subnet.id
#}

resource "aws_launch_configuration" "launchconf" {
  image_id      = var.app_ami_id
  instance_type = var.instance_type
  lifecycle {
    create_before_destroy = true
  }
  key_name = "eng103a_fred_new"
  associate_public_ip_address = true
  security_groups = [aws_security_group.fred_security_group.id]
  user_data = <<EOF
#!/bin/bash
sudo apt-get update -y && sudo apt-get upgrade -y
sudo apt-get install nginx -y
sudo apt-get install python-software-properties -y
curl -sL https://deb.nodesource.com/setup_6.x | sudo -E bash -
sudo apt-get install nodejs -y
cp /home/ubuntu/default /etc/nginx/sites-available/
systemctl restart nginx
systemctl enable nginx
cd /home/ubuntu
node seed/seeds.js
npm install
screen -d -m npm start
EOF
}
 
 resource "aws_autoscaling_group" "asg" {
  name                      = "fred_terraform_asg"
  min_size                  = 3
  max_size                  = 6
  health_check_grace_period = 300
  health_check_type         = "ELB"
  desired_capacity          = 3
  launch_configuration      = aws_launch_configuration.launchconf.name
  vpc_zone_identifier       = [aws_subnet.terraform_subnet.id]
  force_delete = true
  tag {
    key                 = "Name"
    value               = "fred_terraform_asg"
    propagate_at_launch = true
  }
  timeouts {
    delete = "15m"
  }


}

# autoscaling policies for cloudwatch alarm actions (up and down)
resource "aws_autoscaling_policy" "asgpolicy" {
  name = "fred_terraform_policy_up"
  cooldown = 100
  scaling_adjustment = 1
  adjustment_type = "ChangeInCapacity"
  autoscaling_group_name = aws_autoscaling_group.asg.name
}

resource "aws_autoscaling_policy" "asgpolicydown" {
  name = "fred_terraform_policy_down"
  cooldown = 100
  scaling_adjustment = -1
  adjustment_type = "ChangeInCapacity"
  autoscaling_group_name = aws_autoscaling_group.asg.name
}

# cloudwatch alarm setup (over 60% cpu util and under 20% cpu util autoscales)
resource "aws_cloudwatch_metric_alarm" "cloudwatchalarm" {
  alarm_name          = "greaterthan80alarm"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = "2"
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = "30"
  statistic           = "Average"
  threshold           = "60"

  dimensions = {
    AutoScalingGroupName = aws_autoscaling_group.asg.name
  }

  alarm_description = "This metric monitors ec2 cpu utilization"
  alarm_actions     = [aws_autoscaling_policy.asgpolicy.arn]
}

resource "aws_cloudwatch_metric_alarm" "cloudwatchalarm2" {
  alarm_name          = "lowerthan20alarm"
  comparison_operator = "LessThanOrEqualToThreshold"
  evaluation_periods  = "1"
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = "30"
  statistic           = "Average"
  threshold           = "20"

  dimensions = {
    AutoScalingGroupName = aws_autoscaling_group.asg.name
  }

  alarm_description = "This metric monitors ec2 cpu utilization"
  alarm_actions     = [aws_autoscaling_policy.asgpolicydown.arn]
}

resource "aws_alb" "loadbalancer" {
  name               = "fred-load-balancer"
  security_groups    = [aws_security_group.fred_security_group.id]
  subnets            = [aws_subnet.terraform_subnet.id, aws_subnet.terraform_subnet2.id, aws_subnet.terraform_subnet3.id]
  tags = {
    Name = "fred-load-balancer"
  }
}

# attach the application load balancer to the autoscaling group
resource "aws_autoscaling_attachment" "asg_attachment" {
  autoscaling_group_name = aws_autoscaling_group.asg.id
  lb_target_group_arn = aws_alb_target_group.targetgroup.arn
}

resource "aws_alb_target_group" "targetgroup" {
  name     = "fred-alb-target"
  port     = 80
  protocol = "HTTP"
  vpc_id   = aws_vpc.terraform_vpc_code_test.id
}
# set up an application load balancer listener to hear requests at port 80
resource "aws_alb_listener" "listener_http" {
  load_balancer_arn = aws_alb.loadbalancer.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    target_group_arn = aws_alb_target_group.targetgroup.arn
    type             = "forward"
  }
}
```
