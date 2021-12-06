#!/bin/bash

set -x

while read line
do
    if [[ ! "${line}" =~ $(hostname) ]]; then
        echo ${line} >> /etc/hosts
    fi
done </vagrant/hosts

export DEBIAN_FRONTEND=noninteractive

add-apt-repository ppa:landscape/16.06
apt-get update

echo "America/Sao_Paulo" > /etc/timezone
dpkg-reconfigure tzdata
locale-gen pt_BR.UTF-8
update-locale LANG="pt_BR.UTF-8" LANGUAGE="pt_BR"
dpkg-reconfigure locales

apt-get dist-upgrade -y

case $(hostname) in
  landscape-server*)
     echo "Provisioning SERVER instance"
     apt-get install ntp landscape-server-quickstart -y
     echo "ssl_public_key = /etc/ssl/certs/landscape_server_ca.crt" >> /etc/landscape/client.conf
     cp /etc/ssl/certs/landscape_server_ca.crt /vagrant
     # landscape-config --computer-title "$(hostname)" --account-name standalone  --url https://landscape-server.vagrant.local/message-system --ping-url http://landscape-server.vagrant.local/ping --silent
     ;;
  landscape-client*)
    echo "Provisioning CLIENT instances"
    apt-get install ntp -y
    echo "ssl_public_key = /vagrant/landscape_server_ca.crt" >> /etc/landscape/client.conf
    landscape-config --computer-title "$(hostname)" --account-name standalone  --url https://landscape-server.vagrant.local/message-system --ping-url http://landscape-server.vagrant.local/ping --silent
    ;;
  *)
    echo "Provisioning GENERIC instances"
    apt-get install ntp -y
    ;;
esac

apt-get remove chef puppet --purge -y

apt-get autoremove -y

apt-get clean

update-alternatives --set editor /usr/bin/vim.basic

sed -i 's/#force_color_prompt=yes/force_color_prompt=yes/g' /home/vagrant/.bashrc
sed -i 's/#force_color_prompt=yes/force_color_prompt=yes/g' /root/.bashrc
