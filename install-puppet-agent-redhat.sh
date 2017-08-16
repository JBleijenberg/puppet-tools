#!/bin/bash

# Check if puppet is already installed and running
if pgrep puppet > /dev/null 2>&1; then
    echo Puppet is already runnung
    
    exit 1;
else
    if rpm -qa | grep "puppet-" > /dev/null 2>&1; then
        echo Puppet is already installed
    
        exit 1;
    fi
fi

# Get CentOS version
VERSION = `cat /etc/redhat-release | awk '{print substr($4, 0, 1)}'`;

# Get and present the option to change hostname 
echo "Current hostname is set to `hostnamectl status --static`."
read -n 1 -p "Do you want to change it before running puppet? [Y/n]: " "changehostname"
echo ""

if [ "$changehostname" == "y" ] || [ "$changehostname" == "Y" ]; then
    read -p "What is the new hostname?: " "newhost"
    echo ""
    hostnamectl set-hostname $newhost
    echo "Changed hostname to $newhost. Done!"
else
    echo "Not changing hostname. Done."
fi

# Install puppet
rpm -ivh https://yum.puppetlabs.com/puppetlabs-release-el-${VERSION}.noarch.rpm
yum clean all
yum install puppet -y

# Add puppet master to hostsfile
puppet apply -e "host { 'puppet': ip => '149.210.176.197', host_aliases => 'puppet'}"
