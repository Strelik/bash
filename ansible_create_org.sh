
#Creates a basic organization structure based on the ansible docs recommendations under /etc.
sudo mkdir /etc/ansible/group_vars ; sudo mkdir /etc/ansible/host_vars 
sudo mkdir -p /etc/ansible/roles/common
for x in tasks handlers templates files vars meta ; do sudo mkdir -p /etc/ansible/roles/common/$x ; done
