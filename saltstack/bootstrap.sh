#!/bin/bash

set -x

while read line
do
    if [[ ! "${line}" =~ $(hostname) ]]; then
        echo ${line} >> /etc/hosts
    fi
done </vagrant/hosts

export DEBIAN_FRONTEND=noninteractive

echo "deb http://debian.saltstack.com/debian jessie-saltstack main" > /etc/apt/sources.list.d/saltstack.list

wget -q -O- "http://debian.saltstack.com/debian-salt-team-joehealy.gpg.key" | apt-key add -

apt-get update

echo "America/Sao_Paulo" > /etc/timezone
dpkg-reconfigure tzdata
sed -i -e 's/# pt_BR.UTF-8 UTF-8/pt_BR.UTF-8 UTF-8/' /etc/locale.gen
echo 'LANG="pt_BR.UTF-8"'>/etc/default/locale
dpkg-reconfigure locales
update-locale LANG=pt_BR.UTF-8

apt-get dist-upgrade -y

apt-get install ntp vim -y

apt-get autoremove -y

apt-get clean

update-alternatives --set editor /usr/bin/vim.basic

sed -i 's/\"syntax on/syntax on/g' /etc/vim/vimrc

if [[ $(hostname) = "master" ]]; then
   apt-get install salt-master salt-minion -y
   sed -i 's/ master/ master salt/g' /etc/hosts
fi

if [[ $(hostname) =~ "minion" ]]; then
   apt-get install salt-minion -y
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
