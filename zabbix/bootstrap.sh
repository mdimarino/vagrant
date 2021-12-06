#!/bin/bash

set -x

while read line
do
    if [[ ! "${line}" =~ $(hostname) ]]; then
        echo ${line} >> /etc/hosts
    fi
done </vagrant/hosts

export DEBIAN_FRONTEND=noninteractive

wget http://repo.zabbix.com/zabbix/3.0/debian/pool/main/z/zabbix-release/zabbix-release_3.0-1+jessie_all.deb
dpkg -i zabbix-release_3.0-1+jessie_all.deb

apt-get update

echo "America/Sao_Paulo" > /etc/timezone
dpkg-reconfigure tzdata
sed -i -e 's/# pt_BR.UTF-8 UTF-8/pt_BR.UTF-8 UTF-8/' /etc/locale.gen
echo 'LANG="pt_BR.UTF-8"'>/etc/default/locale
dpkg-reconfigure locales
update-locale LANG=pt_BR.UTF-8

apt-get dist-upgrade -y

apt-get install -y ntp vim

apt-get autoremove -y

apt-get clean

update-alternatives --set editor /usr/bin/vim.basic

sed -i 's/\"syntax on/syntax on/g' /etc/vim/vimrc

if [[ $(hostname) = "zabbix-server" ]]; then
   apt-get install zabbix-server-mysql zabbix-frontend-php nmap -y

   mysql -uroot -e "create database zabbix character set utf8 collate utf8_bin;"
   mysql -uroot -e "grant all privileges on zabbix.* to zabbix@localhost identified by 'zabbix';"

   cd /usr/share/doc/zabbix-server-mysql
   zcat create.sql.gz | mysql -uroot zabbix
   sed -i "s/# DBPassword=/DBPassword=zabbix/g" /etc/zabbix/zabbix_server.conf
   service zabbix-server start

   sed -i 's/;date.timezone =/date.timezone = America\/Sao_Paulo/g' /etc/php5/apache2/php.ini
   service apache2 restart

   cp /vagrant/exim4.conf.localmacros /etc/exim4
   mv /etc/exim4/update-exim4.conf.conf /etc/exim4/update-exim4.conf.conf.ORG
   cp /vagrant/update-exim4.conf.conf /etc/exim4
   mv /etc/exim4/passwd.client /etc/exim4/passwd.client.ORG
   cp /vagrant/passwd.client /etc/exim4
   chown root:Debian-exim /etc/exim4/passwd.client
   service exim4 restart
fi

if [[ $(hostname) =~ "zabbix-client" ]]; then
   apt-get install zabbix-agent -y
   sed -i 's/Server=127.0.0.1/Server=zabbix-server.vagrant/g' /etc/zabbix/zabbix_agentd.conf
   sed -i 's/ServerActive=127.0.0.1/ServerActive=zabbix-server.vagrant/g' /etc/zabbix/zabbix_agentd.conf
   sed -i "s/Hostname=Zabbix server/Hostname=$(hostname)/g" /etc/zabbix/zabbix_agentd.conf
   service zabbix-agent restart
fi

sed -i 's/# export LS/export LS/g' /root/.bashrc
sed -i 's/# eval /eval /g' /root/.bashrc
sed -i 's/# alias ls/alias ls/g' /root/.bashrc
sed -i 's/# alias ll=/alias ll=/g' /root/.bashrc
sed -i 's/# alias l=/alias l=/g' /root/.bashrc

sed -i 's/#alias ll=/alias ll=/g' /home/vagrant/.bashrc
sed -i 's/#alias la=/alias la=/g' /home/vagrant/.bashrc
sed -i 's/#alias l=/alias l=/g' /home/vagrant/.bashrc
sed -i 's/#force_color_prompt=yes/force_color_prompt=yes/g' /home/vagrant/.bashrc
