#!/bin/bash
yum install httpd -y
echo "Subnet: ${subnets}" >> /var/www/html/index.html
service httpd start
chkconfig httpd on
