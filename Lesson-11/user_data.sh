#!/bin/bash
yum -y update
yum -y install httpd

myIp='curl http://169.254.169.254/latest/meta-data/local-ipv4'

cat <<EOF > /var/www/html/index.html
<html>
<body bgcolor="white">
</html>
<h2>Stan's WebServer with IP: $myIp</h2>
<br>Build by Terraform
<b>Version 1.0</b>
EOF

service httpd start
chkconfig httpd on