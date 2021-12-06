#!/bin/bash

set -x

while read line
do
    if [[ ! "${line}" =~ $(hostname) ]]; then
        echo ${line} >> /etc/hosts
    fi
done </vagrant/hosts

export DEBIAN_FRONTEND=noninteractive

echo "deb http://download.webmin.com/download/repository sarge contrib" > /etc/apt/sources.list.d/webmin.list
echo "deb http://webmin.mirror.somersettechsolutions.co.uk/repository sarge contrib" >> /etc/apt/sources.list.d/webmin.list

curl http://www.webmin.com/jcameron-key.asc | apt-key add -

apt-get update

echo "America/Sao_Paulo" > /etc/timezone
dpkg-reconfigure tzdata
locale-gen pt_BR.UTF-8
update-locale LANG="pt_BR.UTF-8" LANGUAGE="pt_BR"
dpkg-reconfigure locales

apt-get dist-upgrade -y

apt-get install -y chrony mysql-server webmin apache2 php5 php5-mysql libapache2-mod-php5 php5-gd libapache2-mod-perl2 libdbi-perl libxml-simple-perl libcompress-raw-zlib-perl libdbd-mysql-perl libapache-dbi-perl libnet-ip-perl libsoap-lite-perl make libphp-pclzip nmap

apt-get autoremove -y

apt-get clean

update-alternatives --set editor /usr/bin/vim.basic

sed -i 's/#force_color_prompt=yes/force_color_prompt=yes/g' /home/vagrant/.bashrc
sed -i 's/#force_color_prompt=yes/force_color_prompt=yes/g' /root/.bashrc

mysql -e "SET PASSWORD FOR 'root'@'localhost' = PASSWORD('root');"
echo -e "[client]\nuser=root\npassword=root\n" > /root/.my.cnf
mysql -e "SET PASSWORD FOR 'root'@'127.0.0.1' = PASSWORD('root');"
mysql -e "SET PASSWORD FOR 'root'@'::1' = PASSWORD('root');"
mysql -e "DELETE FROM mysql.user WHERE User='root' AND Host NOT IN ('localhost', '127.0.0.1', '::1');"
mysql -e "CREATE DATABASE ocsweb CHARACTER SET utf8 COLLATE utf8_general_ci;"
mysql -e "CREATE USER 'ocs'@'localhost' IDENTIFIED BY 'ocs';"
mysql -e "GRANT ALL PRIVILEGES ON ocsweb.* TO 'ocs'@'localhost';"
mysql -e "FLUSH PRIVILEGES;"

/usr/share/webmin/changepass.pl /etc/webmin root root

cpan -i XML::Entities

tar xzf /vagrant/OCSNG_UNIX_SERVER-2.1.2.tar.gz -C /var/www

##sed -i 's/max_execution_time = 30/max_execution_time = 600/g' /etc/php5/apache2/php.ini
