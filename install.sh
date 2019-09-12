#!/bin/bash

domain=virtual-example.com
docRoot=/var/www
hostDir=/vagrant
httpdPath=/etc/httpd
php=php
publicPath="/public"
commonPath=$hostDir/common
vhScript=$hostDir/scripts/generate_vhost.sh

sudo mkdir $docRoot
sudo mkdir -p $hostDir/html
sudo mkdir -p $hostDir/log
sudo ln -s $hostDir/html $docRoot/html
sudo ln -s $hostDir/log $docRoot/log

sudo yum update -y

# common utils
sudo cp $commonPath/repo/dos2unix-6.0.3-7.el7.src.rpm /etc/yum.repos.d/
sudo yum install -y epel-release htop nano dos2unix

# apache
sudo yum update -y
sudo yum install -y httpd mod_fcgid
sudo cp $commonPath/conf/httpd.conf $httpdPath/conf/httpd.conf
sudo mkdir $httpdPath/sites-available
sudo mkdir $httpdPath/sites-enabled

# template
echo "##### Generating sites filesystems #####"
sudo dos2unix $vhScript
sudo bash $vhScript $domain 80 $publicPath $php

# php
sudo rpm -Uvh http://rpms.remirepo.net/enterprise/remi-release-7.rpm
sudo yum -y update
sudo yum-config-manager --enable remi-php71
sudo yum -y install $php
php -v
# extensions
sudo yum --enablerepo=remi install -y $php-opcache $php-mcrypt $php-fpm $php-intl $php-gmp $php-imap $php-ldap $php-mbstring $php-mysqli $php-pdo_odbc $php-pdo_pgsql $php-redis $php-redis $php-soap $php-tidy $php-xmlrpc $php-zip
# imagick
sudo yum install -y gcc php-devel php-pear ImageMagick ImageMagick-devel
sudo pecl install imagick
sudo cp $commonPath/ini/imagick.ini /etc/php.d/
sudo service httpd restart

# redis
sudo yum install -y redis
sudo systemctl start redis

# mariaDB
sudo cp $commonPath/repo/mariadb.repo /etc/yum.repos.d/
sudo yum install -y MariaDB-server
sudo systemctl start mariadb

# fast-cgi
#sudo a2enmod actions alias proxy_fcgi fcgid
#sudo service apache2 restart