#!/bin/bash

set -x

while read line
do
    if [[ ! "${line}" =~ $(hostname) ]]; then
        echo ${line} >> /etc/hosts
    fi
done </vagrant/hosts

export DEBIAN_FRONTEND=noninteractive

apt-get install python-software-properties -y

add-apt-repository ppa:webupd8team/java -y

apt-get update

echo "America/Sao_Paulo" > /etc/timezone
dpkg-reconfigure tzdata
locale-gen pt_BR.UTF-8
update-locale LANG="pt_BR.UTF-8" LANGUAGE="pt_BR"
dpkg-reconfigure locales

apt-get dist-upgrade -y

echo debconf shared/accepted-oracle-license-v1-1 select true | debconf-set-selections
echo debconf shared/accepted-oracle-license-v1-1 seen true | debconf-set-selections

apt-get install oracle-java8-installer -y

apt-get autoremove -y

apt-get clean

update-alternatives --set editor /usr/bin/vim.basic

sed -i 's/#force_color_prompt=yes/force_color_prompt=yes/g' /home/vagrant/.bashrc
sed -i 's/#force_color_prompt=yes/force_color_prompt=yes/g' /root/.bashrc

groupadd app

useradd -c "Application User Account" -d /srv/app -g app -m -s /bin/bash app

wget http://mirror.nbtelecom.com.br/apache/tomcat/tomcat-8/v8.5.4/bin/apache-tomcat-8.5.4.tar.gz

tar xzf apache-tomcat-8.5.4.tar.gz -C /srv/app

chown -R app:app /srv/app/apache-tomcat-8.5.4
