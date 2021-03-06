# IAC with Ansible


### Let's create Vagrantfile to create Three VMs for Ansible architecture
#### Ansible controller and Ansible agents 

See base file from Shahrukh or vagrant file.
![IaC](https://user-images.githubusercontent.com/39882040/154721992-c3924d93-4ca3-466e-a5df-14f60ca6a057.png)
# Infrastructure as Code (IaC)
Ansible and Terraform are used to work with infrastructure as code. They can be used for configuration management and orchestration. Ansible is used for push to config, it's an automation script, terraform is used for orchestration. Ansible YAML/YML file.yml/ yaml (yet another mark up language).
In order to set up the virtual machines, create a new directory on your computer and clone from the link sent (insert link here). Once it has been cloned, go into the correct directory and `vagrant up`, this will trigger the provisions file which will set up the machines. SSH into the machines `vagrant ssh machine_name` and check whether they have internet access using the update and upgrade commands.

Ansible is Agentless?
It's simple, you can install everything you need, no heavy dependencies. It's like operating the DLR, you only need to programm directions and behavior for the train, when it's in service it doesn't need someone there to manage it. So Ansible allows us to manage multiple VM/instances without going into them using SSH.


# Ansible setup
Setting up the VMs:
- create a local directory and clone the github into it( Shahrukh eng99_IaC_ansible)
- Once it has been cloned go to the correct directory on visual studio and type `vagrant up`. This will trigger the vagrant file and it will set up the VMs
- When that has finished type `vagrant status` to see if they are all running
- SSH into each VM and do the update and upgrade commands to see if there is internet access. The 3 VMs are controller,db, and web.

Setting up Ansible controller make sure you are in the controller VM:
- install required dependencies i.e python `sudo apt-get install software-properties-common`
- install ansible repository `sudo apt-add-repository ppa:ansible/ansible`
- `sudo apt-get install ansible` to install ansible. check version using `ansible --version`
-  default folder structures /etc/ansible `cd /etc/ansible` to get into the right directory
-  Install tree `sudo apt install tree`, this allows us to get a better view of files when you type `tree`
- host file - agent node called web ip of the web (sudo nano /etc/ansible/hosts)
- IP of web is `192.168.33.10`, IP of db is `192.168.33.11`
- In order to enter a machine go to /etc/ansible , `ssh vagrant@IP` for example `ssh vagrant@192.168.33.10` to ssh into web. When you ssh in, you need to put a password in, which is vagrant.
- use ping to see if it is connected to the other VMs `ping IP`
- `ansible web -m ping` to ping a certain machine, first time this won't work so we need to edit the host file
- In the host file put the command `[web]` and under it put the line `192.168.33.10` This is the IP address of web. This time it will connect to it but it will not be able to connect, unreachable.
- So now go back into the hosts file and add to the IP line `ansible_connection=ssh ansible_ssh_user=vagrant ansible_ssh_pass=vagrant`. Now the ping should be able to work. It will return Pong.
- Now do the same steps for db. However, when you write on host file leave `ansible_ssh_pass=vagrant` out and run ping. Press yes on the command and when it fails go back into the host file and put the pass back into the file. Both pings should work now.
- Create a read me and copy it over using the copy command bellow.
- use `ansible all -a ls` to see all the directories

### Ansible Adhoc commands
- `ansible db -m ping` - pings the db VM
- `ansible all -m ping` -pings all the available VMs
- `ansible web -a "uname -a"` -returns the information about the instance (The -a is used to run specific commands for a system)
- `ansible all -a "uname -a"` -returns the information about all the instance 
- `ansible all -a "free"` - returns information about memory
- `ansible web -m copy -a "src=/etc/ansible/README.md dest=/home/vagrant/README.md"` will copy a file from controller to web, the src is the source directory and dest is the destination directory
- `ansible all -a ls` will show all the files in directories in VMs.
- `ansible-playbook filename.yml` to run a playbook
- `ansible web -a "systemctl status nginx"` will check the status of nginx in web

## Ansible playbooks
What are playbooks?
- YAML/yml files with scripts to implement config management, they save time and they are reuseable
- Creating a playbook: filename.yml/yaml
- yml/yaml files starts with three dashes ---
- Indentation is extremely important, check video for indentation
- When playbook file is complete. Run them using `ansible-playbook filename.yml`
- import package name (pytest) Ansible uses python in the background
- import file.yml

This code will copy the app file from the local computer to the ansible controller instance.
```
# yml file to copy the app over

- hosts: web

  gather_facts: yes

  become: true

  tasks:
   - name: moving app folder in
     synchronize:
       src: /home/vagrant/app
       dest: ~/
```
This code will install nodejs, the required packages and start the app
```
#Yml file to create a playbook to set up nodejs
---
- hosts: web

  gather_facts: yes

  become: true

  tasks:
  - name: load a specific version of nodejs
    shell: curl -sL https://deb.nodesource.com/setup_6.x | sudo -E bash -

  - name: install the required packages
    apt:
      pkg:
        - nginx
        - nodejs
        - npm
      update_cache: yes
  - name: install and run the appy
    shell:
       cd app/app; npm install; screen -d -m npm start
```
The code for db and reverse proxy. It will also install the specific version of nodejs, install the required packages, create the variable for the db IP, and start the app and keep it running.
```
#Yml file to create a playbook to set up nodejs and connect to db, reverse proxy WIP
---
- hosts: web

  gather_facts: yes

  become: true

  tasks:
  -  name: load a specific version of nodejs
     shell: curl -sL https://deb.nodesource.com/setup_6.x | sudo -E bash -

  -  name: install the required packages
     apt:
       pkg:
         - nginx
         - nodejs
         - npm
       update_cache: yes
  -  name: nginx configuration for reverse proxy
     synchronize:
       src: /home/vagrant/app/app/default
       dest: /etc/nginx/sites-available/default
  -  name: nginx restart
     service: name=nginx state=restarted
  -  name: nginx enable
     service: name=nginx enabled=yes
  -  name: install and run the app
     become_user: vagrant
     environment:
       DB_HOST: mongodb://192.168.33.11:27017/posts
     shell:
        cd app/app; node seeds/seed.js; npm install; screen -d -m npm start
```
The code below, is the code for installing mongo, and making sure mongodb is present and enabled. 
```
---
-  hosts: db
   gather_facts: yes
   become: true
   tasks:
   - name: installing mongo
     apt:
       name: mongodb
       state: present
   - name: allow 0.0.0.0
     ansible.builtin.lineinfile:
       path: /etc/mongodb.conf
       regexp: '^bind_ip = '
       line: bind_ip = 0.0.0.0
   - name: restart mongodb
     service: name=mongodb state=restarted
   - name: mongod enable
     service: name=mongodb enabled=yes
```
![error](https://user-images.githubusercontent.com/39882040/154725514-5943db68-7623-43b5-b533-250fcccd9823.PNG)

# Hybrid IaC
![IaC AWS](https://user-images.githubusercontent.com/39882040/155287231-aa03b961-970d-44fc-b904-f2e9e3817ae1.PNG)

The diagram above shows the setup for a hybrid ansible configuration. The controller on AWS is initially created using an ansible playbook on the prem localhost. To create it you need the playbook, key permission (generat key), and the vault password. 

- Set up AWS access and secret keys using ansible vault
- need to have pem file
- Create a password for connection to AWS for ansible vault

Steps:
- Create a new VM (not the old controller)
- set up ansible controller to use in hybrid infrastructure from on prem - public cloud
- install required dependencies
- python3, pip3, awscll,ansible- boto boto3 python's package
- tree
- In order to download and install ansible we need to get the repository first
- Use git bash as admin
- alias python=python3

Set up ansible vault
- aws access and secret keys
- ansible-vault default folder structure
- create a file.yml to store AWS keys
- chmod 600 file.yml
- ansible db -m ping --ask-vault-pass (will ask us to enter password)

The code below should set up the pass file. I had a blocker on here so I had to do it again, so do the steps carefully.
```
sudo apt-get update -y
sudo apt-get upgrade -y
sudo apt-get install tree
sudo apt-add-repository --yes --update ppa:ansible/ansible
sudo apt-get install ansible
sudo apt-get install python3-pip
pip3 install awscli
pip3 install boto boto3
aws --version (need to restart git bash for this to work)
cd /etc/ansible/group_vars/all
sudo ansible-vault create pass.yml
cd ..
cd ..
sudo chmod 600 pass.yml
cd group_vars/all
sudo ansible all -m ping --ask-vault-pass
```

The playbook I used for the creation of the instance is shown below.

```
---
- hosts: localhost
  connection: local
  gather_facts: yes
  vars_files:
  - group_vars/all/pass.yml
  tasks:
  - ec2:
      aws_access_key: "{{aws_access_key}}"
      aws_secret_key: "{{aws_secret_key}}"
      key_name: eng103a
      instance_type: t2.micro
      image: ami-07d8796a2b0f8d29c
      wait: yes
      group: default
      region: "eu-west-1"
      count: 1
      vpc_subnet_id: subnet-0752a4cb9e3db4216
      assign_public_ip: yes
      instance_tags:
        Name: FredPlayBook
```
Make sure the eng103a.pem file is in the /etc/ansible directory. You can also put it in the right location on microsoft visual studio. This can be done with the command `sudo scp file-to-move.pem vagrant@192.168.33.10:~/.ssh/`. This will move the access file to the virtual machine.In order to be able to communicate with the aws instance, you need to edit the `Host` file.you need to put in a name(aws in our case), the IP,ansible user, and the pem file used to connect with it.This can be seen in the image below.
![image](https://user-images.githubusercontent.com/39882040/154998271-851d177a-56db-4e12-8d70-8f43548a48c1.png)
 
 Make sure you ping the aws instance using the command `ansible all -m ping --ask-vault-pass`. If the ping is successful then you can move onto the ssh. This can be done with the command `sudo ssh -i "file.pem" ubuntu@instance_ip`. 

The code below sets up nginx on the instance. This is similar to some of the code from earlier but the `hosts` is changed to match the AWS instance.
```
#Yaml file to start nginx
---
- hosts: aws

  gather_facts: yes

  become: true

  tasks:
  - name: install nodejs
    shell: url -sL https://deb.nodesource.com/setup_6.x | sudo -E bash -
  - name: Installing Nginx web-sever in our app machine
    apt:
      pkg:
        - nginx
        - nodejs
        - npm
      update_cache: yes
  - name: run the app
    shell:
       cd app/app; node seeds/seed.js; npm install; screen -d -m npm start
```
Some blockers today include:
- access denied - use sudo - aws unreachable - check your keys in pass.yml
- ansible-vault edit pass.yml
- can't ssh in - ensure the location of .pem file is 100% correct
- .pem file must be in .ssh folder of your controller
- playbook runs but does not launch ec2 - add tags at the end of command

# Controller on AWS

Steps to do:
- step 1: set up a controller on an EC2 instance
- step 2: Set up ansible vault with AWS access and secret keys. Must not copy aws keys on aws controller, encrypt keys
- step 3: launch another instance for app from the AWS ansible controller
- step 4: ping your app instance and SSH into your app instance from your controller
- step 5: run your playbooks to push configurations, test nginx, reverse proxy etc. Once that is all done, launch your db instance. Do not launch the db instance until you have set up your app instance

The code below stats the instace. Some thigns on here need to be changed in the future. The `id_rsa` is a key that was created for the access. This key can be generated using `ssh-keygen -t rsa -b 4096`. 

For the reverse proxy the default file was moved from the prem to the instance using the command ` scp -i "~/.ssh/eng103a.pem" default ubuntu@3.248.212.62:~`
```
---
- hosts: localhost
  connection: local
  gather_facts: yes
  vars_files:
  - group_vars/all/pass.yml
  tasks:
  - ec2_key:
      name: id_rsa
      key_material: "{{ lookup('file', '/home/ubuntu/.ssh/id_rsa.pub') }}"
      region: "eu-west-1"
      aws_access_key: "{{aws_access_key}}"
      aws_secret_key: "{{aws_secret_key}}"
  - ec2:
      aws_access_key: "{{aws_access_key}}"
      aws_secret_key: "{{aws_secret_key}}"
      key_name: id_rsa
      instance_type: t2.micro
      image: ami-0829dd07f85c1b677
      wait: yes
      group: default
      region: "eu-west-1"
      count: 1
      vpc_subnet_id: subnet-0752a4cb9e3db4216
      assign_public_ip: yes
      instance_tags:
        Name: FredPlayBook-db
```
This code is the db_conf code
```
---
-  hosts: aws-db
   gather_facts: yes
   become: true
   tasks:
   - name: installing mongo
     apt:
       name: mongodb
       state: present
   - name: allow 0.0.0.0
     ansible.builtin.lineinfile:
       path: /etc/mongodb.conf
       regexp: '^bind_ip = '
       line: bind_ip = 0.0.0.0
   - name: restart mongodb
     service: name=mongodb state=restarted
   - name: mongod enable
     service: name=mongodb enabled=yes
```
This code below does the restart for nginx
```
---
- hosts: aws-app
  gather_facts: yes
  become: true
  tasks:
  - name: restart and enable nginx
    service: name=nginx state=restarted enabled=yes
```
This code installs some of the useful installed app
```
---
- hosts: aws-app

  gather_facts: yes

  become: true

  tasks:
  - name: install nodejs
    shell: url -sL https://deb.nodesource.com/setup_6.x | sudo -E bash -
  - name: Installing Nginx web-sever in our app machine
    apt:
      pkg:
        - nginx
        - nodejs
        - npm
      update_cache: yes
  -  name: nginx configuration for reverse proxy
     copy:
       src: /home/ubuntu/default
       dest: /etc/nginx/sites-available/
       force: yes
  #- name: run the app
 #   shell:
#       export DB_HOST=mongodb://3.251.91.190:27017/posts; cd app/app; node seeds/seed.js; npm install; screen -d -m npm start
```
# Infrastructure as Code-Terraform
Terraform is an example of IaC, it is used for infrastructure provisioning. The language it uses is GO. It can be used to provision stuff like VPCs, subnets, etc automatically, and in tandem with ansible can set up a environment automatically.

 The command  `sudo ansible-playbook start.yaml --ask-vault-pass -e ansible_python_interpreter=/usr/bin/python3 -v`, will run the  ansible play book called `start.yaml`, will have vault permission (so you'll have to enter a password), it will also use python 3 and give you information on the running of it. If there are any issues.

 ```
 [aws]
PUBLIC IP ansible_connection=ssh ansible_ssh_user=ubuntu ansible_ssh_private_key_file=/home/vagrant/.ssh/PRIVATEKEY
 ```

 The command used to move the app folder from the desktop to the instance was:
 `scp -i "~/.ssh/name_of_pemfile.pem" -r app ubuntu@public_IP.eu-west-1.compute.amazonaws.com:~/`

 In the part between quotation marks, you would normally give the file directory for the pem file, -r means it takes all of it, this was done from desktop so no directory is needed for app but normally you would have to give a directory, and the last part is the identity of the ec2 instance, see public IPv4 and ubuntu in our case