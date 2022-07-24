#!/bin/bash
sudo yum install mysql -y
mysql -u$1 -p$2 -h$3 -e "CREATE DATABASE wordpress; CREATE USER 'wordpress'@'%' IDENTIFIED BY 'PASSWORD'; GRANT ALL PRIVILEGES ON wordpress.* TO 'wordpress'@'%'; FLUSH PRIVILEGES;"
