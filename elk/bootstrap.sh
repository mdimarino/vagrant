#!/bin/bash

set -x

while read line
do
    if [[ ! "${line}" =~ $(hostname) ]]; then
        echo ${line} >> /etc/hosts
    fi
done </vagrant/hosts

export DEBIAN_FRONTEND=noninteractive

add-apt-repository -y ppa:webupd8team/java

wget -qO - https://packages.elastic.co/GPG-KEY-elasticsearch | apt-key add -

echo "deb https://packages.elastic.co/elasticsearch/2.x/debian stable main" | tee -a /etc/apt/sources.list.d/elasticsearch-2.x.list

echo "deb https://packages.elastic.co/logstash/2.3/debian stable main" | tee -a /etc/apt/sources.list.d/logstash.list

echo "deb http://packages.elastic.co/kibana/4.5/debian stable main" | tee -a /etc/apt/sources.list.d/kibana.list

echo oracle-java8-installer shared/accepted-oracle-license-v1-1 select true | /usr/bin/debconf-set-selections

apt-get update

echo "America/Sao_Paulo" > /etc/timezone
dpkg-reconfigure tzdata
locale-gen pt_BR.UTF-8
update-locale LANG="pt_BR.UTF-8" LANGUAGE="pt_BR"
dpkg-reconfigure locales

apt-get dist-upgrade -y

apt-get install ntp oracle-java8-installer elasticsearch logstash kibana -y

apt-get remove chef puppet --purge -y

apt-get autoremove -y

apt-get clean

update-alternatives --set editor /usr/bin/vim.basic

update-rc.d elasticsearch defaults 95 10

update-rc.d logstash defaults 95 10

update-rc.d kibana defaults 95 10

sed -i 's/#force_color_prompt=yes/force_color_prompt=yes/g' /home/vagrant/.bashrc
sed -i 's/#force_color_prompt=yes/force_color_prompt=yes/g' /root/.bashrc
