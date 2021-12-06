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

apt-get install -y php php-mysql php-curl php-gd php-json php-mbstring php-xml php-cli php-imap php-ldap php-xmlrpc php-apcu libapache2-mod-php apache2 exim4 webmin

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
mysql -e "CREATE DATABASE glpi CHARACTER SET utf8 COLLATE utf8_general_ci;"
mysql -e "CREATE USER 'glpi'@'localhost' IDENTIFIED BY 'glpi';"
mysql -e "GRANT ALL PRIVILEGES ON glpi.* TO 'glpi'@'localhost';"
mysql -e "FLUSH PRIVILEGES;"

/usr/share/webmin/changepass.pl /etc/webmin root root

sed -i 's/max_execution_time = 30/max_execution_time = 600/g' /etc/php5/apache2/php.ini

cp /vagrant/exim4.conf.localmacros /etc/exim4
mv /etc/exim4/update-exim4.conf.conf /etc/exim4/update-exim4.conf.conf.ORG
cp /vagrant/update-exim4.conf.conf /etc/exim4
mv /etc/exim4/passwd.client /etc/exim4/passwd.client.ORG
cp /vagrant/passwd.client /etc/exim4
chown root:Debian-exim /etc/exim4/passwd.client

wget -q https://github.com/glpi-project/glpi/releases/download/0.90.1/glpi-0.90.1.tar.gz -O /root/glpi-0.90.1.tar.gz

wget -q https://github.com/glpi-project/glpi/releases/download/9.2.3/glpi-9.2.3.tgz -O /root/glpi-9.2.3.tgz

tar xzf /root/glpi-0.90.1.tar.gz -C /var/www && rm /root/glpi-0.90.1.tar.gz
chgrp -R www-data /var/www/glpi/files /var/www/glpi/config
cp /vagrant/glpi.vagrant.conf /etc/apache2/sites-available/
a2ensite glpi.vagrant.conf
a2dissite 000-default
service apache2 restart
