#!/bin/bash

if grep -q -i "release 6" /etc/redhat-release ; then
 rhel6only=1
    echo "RHEL 6"
    yum --noplugins -q list installed epel-release-latest-6 &>/dev/null && echo "epel-release-latest-6 is installed" || yum install -y https://dl.fedoraproject.org/pub/epel/epel-release-latest-6.noarch.rpm --skip-broken --noplugins
    yum --noplugins -q list installed mongodb-server &>/dev/null && echo "mongodb-server is installed" || yum install -y mongodb-server --skip-broken --noplugins
    yum --noplugins -q list installed ansible &>/dev/null && echo "ansible is installed" || yum install -y ansible --skip-broken --noplugins
    yum --noplugins -q list installed wget &>/dev/null && echo "wget is installed" || yum install -y wget --skip-broken --noplugins
    yum remove -y epel*
    yum clean all
    mkdir -p FILES
    cd ./FILES/

elif grep -q -i "release 7" /etc/redhat-release ; then
 rhel7only=1
    echo "RHEL 7"
    yum --noplugins -q list installed wget &>/dev/null && echo "wget is installed" || yum install -y wget --skip-broken --noplugins\
    yum --noplugins -q list installed epel-release-latest-7 &>/dev/null && echo "epel-release-latest-7 is installed" || yum install -y https://dl.fedoraproject.org/pub/epel/epel-release-latest-7.noarch.rpm --skip-broken --noplugins
    yum --noplugins -q list installed ansible &>/dev/null && echo "ansible is installed" || yum install -y ansible --skip-broken --noplugins
    yum remove -y epel*
    yum clean all
    mkdir -p FILES
    cd ./FILES/
else
 echo "Running neither RHEL6.x nor RHEL 7.x !"
fi

if grep -q -i "release 6" /etc/redhat-release ; then
 rhel6only=1
    echo "RHEL 6 supporting tower 3.0"
    wget https://releases.ansible.com/awx/setup/ansible-tower-setup-3.0.0.tar.gz

elif grep -q -i "release 7" /etc/redhat-release ; then
 rhel7only=1
    echo "RHEL 7 supporting latest release"
    wget https://releases.ansible.com/awx/setup/ansible-tower-setup-latest.tar.gz

else
 echo "Running neither RHEL6.x nor RHEL 7.x !"
fi

tar -zxvf ansible-tower-*.tar.gz
cd ansible-tower*
sed -i s/admin_password="''"/admin_password="'redhat'"/g inventory
sed -i s/redis_password="''"/redis_password="'redhat'"/g inventory
sed -i s/pg_password="''"/pg_password="'redhat'"/g inventory
sed -i s/rabbitmq_password="''"/rabbitmq_password="'redhat'"/g inventory
sh setup.sh
