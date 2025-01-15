#!/bin/bash
yum -y update
yum -y install httpd
myIp='curl http://169.254.169.254/latest/meta-data/local-ipv4'
echo "<h2>Stan's WebServer with IP: $myIp</h2><br>Build by Terraform" > /var/www/html/index.html
sudo service httpd start
chkconfig httpd on