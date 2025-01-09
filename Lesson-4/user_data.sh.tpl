#!/bin/bash
yum -y update
yum -y install httpd

myIp='curl http://169.254.169.254/latest/meta-data/local-ipv4'

cat <<EOF > /var/www/html/index.html
<html>
<h2>Build by Terraform <font color="red"> v0.1</font></h2><br>
Owner ${f_name} ${l_name} <br>

%{ for x in names ~}
Running through ${x} <br>
%{ endfor ~}

</html>
EOF

sudo service httpd start
chkconfig httpd on