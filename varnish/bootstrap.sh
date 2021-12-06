#!/bin/bash

set -x

while read line
do
    if [[ ! "${line}" =~ $(hostname) ]]; then
        echo ${line} >> /etc/hosts
    fi
done </vagrant/hosts

export DEBIAN_FRONTEND=noninteractive

curl -s https://repo.varnish-cache.org/GPG-key.txt | apt-key add -

echo "deb https://repo.varnish-cache.org/ubuntu/ trusty varnish-4.1" >> /etc/apt/sources.list.d/varnish-cache.list

apt-get update

echo "America/Sao_Paulo" > /etc/timezone
dpkg-reconfigure tzdata
locale-gen pt_BR.UTF-8
update-locale LANG="pt_BR.UTF-8" LANGUAGE="pt_BR"
dpkg-reconfigure locales

apt-get dist-upgrade -y

apt-get install -y apache2 varnish

apt-get autoremove -y

apt-get clean

update-alternatives --set editor /usr/bin/vim.basic

sed -i 's/#force_color_prompt=yes/force_color_prompt=yes/g' /home/vagrant/.bashrc
sed -i 's/#force_color_prompt=yes/force_color_prompt=yes/g' /root/.bashrc

sed -i 's/Listen 80/Listen 8080/g' /etc/apache2/ports.conf
sed -i 's/VirtualHost \*:80/VirtualHost \*:8080/g' /etc/apache2/sites-available/000-default.conf
sed -i 's/-a :6081/-a :80/g' /etc/default/varnish
service apache2 restart

sed -i 's/-T localhost:6082/-T localhost:1234/g' /etc/default/varnish
service varnish restart
