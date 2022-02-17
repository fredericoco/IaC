# IAC with Ansible


### Let's create Vagrantfile to create Three VMs for Ansible architecture
#### Ansible controller and Ansible agents 

```

# -*- mode: ruby -*-
 # vi: set ft=ruby :
 
 # All Vagrant configuration is done below. The "2" in Vagrant.configure
 # configures the configuration version (we support older styles for
 # backwards compatibility). Please don't change it unless you know what
 
 # MULTI SERVER/VMs environment 
 #
 Vagrant.configure("2") do |config|
 # creating are Ansible controller
   config.vm.define "controller" do |controller|
     
    controller.vm.box = "bento/ubuntu-18.04"
    
    controller.vm.hostname = 'controller'
    
    controller.vm.network :private_network, ip: "192.168.33.12"
    
    # config.hostsupdater.aliases = ["development.controller"] 
    
   end 
 # creating first VM called web  
   config.vm.define "web" do |web|
     
     web.vm.box = "bento/ubuntu-18.04"
    # downloading ubuntu 18.04 image
 
     web.vm.hostname = 'web'
     # assigning host name to the VM
     
     web.vm.network :private_network, ip: "192.168.33.10"
     #   assigning private IP
     
     #config.hostsupdater.aliases = ["development.web"]
     # creating a link called development.web so we can access web page with this link instread of an IP   
         
   end
   
 # creating second VM called db
   config.vm.define "db" do |db|
     
     db.vm.box = "bento/ubuntu-18.04"
     
     db.vm.hostname = 'db'
     
     db.vm.network :private_network, ip: "192.168.33.11"
     
     #config.hostsupdater.aliases = ["development.db"]     
   end
 
 
 end
```
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