#!/bin/bash

if ! diff -q <(ifconfig) <(ifconfig -a) &>/dev/null; then
	sed -i 's/ONBOOT=no/ONBOOT=yes/g' /etc/sysconfig/network-scripts/ifcfg-eth0
	service network restart
fi

#기본 설치

if ! rpm -qa | grep vim; then
	yum -y update
	yum -y install vim-enhanced.x86_64
fi

#아파치 설치
#https://www.server-world.info/en/note?os=CentOS_6&p=httpd
if ! rpm -qa | grep httpd; then
	yum -y install httpd
	sed -i 's/#ServerName/ServerName/g' /etc/httpd/conf/httpd.conf
	rm -f /etc/httpd/conf.d/welcome.conf
	iptables -I INPUT 5 -p tcp -m state --state NEW -m tcp --dport 80 -j ACCEPT
	service httpd start
fi

#DB 설치
if ! rpm -qa | grep MariaDB; then

cat > /etc/yum.repos.d/MariaDB.repo << EOF
[mariadb]
name = MariaDB
baseurl = http://yum.mariadb.org/10.1/centos6-amd64
gpgkey=https://yum.mariadb.org/RPM-GPG-KEY-MariaDB
gpgcheck=1
EOF

	yum -y install MariaDB-server MariaDB-client
	service mysql start
	chkconfig mysql on
fi

#PHP 설치
if ! rpm -qa | grep php; then
	rpm -Uvh https://dl.fedoraproject.org/pub/epel/epel-release-latest-6.noarch.rpm
	rpm -Uvh https://mirror.webtatic.com/yum/el6/latest.rpm
	yum -y install php56w php56w-common php56w-opcache php56w-mysql php56w-mbstring
	service httpd restart
fi

cat > /var/www/html/index.php << EOF
<?php phpInfo(); ?>
EOF

mysql_secure_installation