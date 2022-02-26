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
npm install
screen -d -m npm start
EOF
}
 
 resource "aws_autoscaling_group" "asg" {
  name                      = "fred_terraform_asg"
  min_size                  = 2
  max_size                  = 4
  health_check_grace_period = 300
  health_check_type         = "ELB"
  desired_capacity          = 2
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