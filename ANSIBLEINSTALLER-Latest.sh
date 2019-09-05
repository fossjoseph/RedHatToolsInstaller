#!/bin/bash
#POC/Demo
#This Script is for setting up a basic Ansible Tower (latest) with Azure and AWS support.
echo -ne "\e[8;40;170t"
reset

#--------------------------required packages for script to run----------------------------
#------------------
function SCRIPT {
#------------------
echo "Checking if prereq have been met to run this script "
HNAME=$(hostname)
DOM="$(hostname -d)"
wget -q --tries=10 --timeout=20 --spider http://google.com
if [[ $? -eq 0 ]]; then
        echo "Online"
else
        echo "Offline"
        echo "This script requires access to 
              the network to run please fix your settings and try again"
              sleep 5
        exit 1
fi
echo "*********************************************************"
echo "ADMIN PASSWORD"
echo "*********************************************************"
echo 'ADMIN=admin' >> /root/.bashrc
echo 'What will the password be for your admin user?'
read ADMIN_PASSWORD
echo 'ADMIN_PASSWORD='$ADMIN_PASSWORD'' >> /root/.bashrc

echo "*************************************************************"
echo "Installing Script configuration requirements for this server"
echo "*************************************************************"
echo "*********************************************************"
echo "SET SELINUX TO PERMISSIVE FOR THE INSTALL AND CONFIG"
echo "*********************************************************"
sed -i 's/SELINUX=enforcing/SELINUX=permissive/g' /etc/selinux/config
setenforce 0
service firewalld stop
chkconfig firewalld off
service firewalld stop
setenforce 0
echo "*********************************************************"
echo "REGESTERING RHEL SYSTEM"
echo "*********************************************************"
subscription-manager register --auto-attach
echo " "
echo "*********************************************************"
echo "SET REPOS ENABLING SCRIPT TO RUN"
echo "*********************************************************"
echo " "
echo "*********************************************************"
echo "SETUP ADMIN SERVICE ACCOUNT USER"
echo "*********************************************************"
source /root/.bashrc
echo -ne "\e[8;40;170t"
sudo groupadd admin
sudo useradd admin --group admin -p $ADMIN
sudo -u admin ssh-keygen -f /home/admin/.ssh/id_rsa -N ''
sudo chown -R admin:admin /home/admin
sudo cp /etc/sudoers /etc/sudoers.bak
sudo echo 'admin ALL = NOPASSWD: ALL' >> /etc/sudoers

echo " "
echo "*********************************************************"
echo "FIRST DISABLE REPOS"
echo "*********************************************************"
sudo subscription-manager repos --disable "*" || exit 1
echo " "
echo " "
echo " "
echo "*********************************************************"
echo "ENABLE PROPER REPOS"
echo "*********************************************************"
if grep -q -i "release 7" /etc/redhat-release ; then
rhel7only=1
echo "RHEL 7.7"
sudo subscription-manager repos --enable=rhel-7-server-rpms || exit 1
sudo subscription-manager repos --enable=rhel-7-server-extras-rpms || exit 1
sudo subscription-manager repos --enable=rhel-7-server-optional-rpms || exit 1
sudo subscription-manager repos --enable=rhel-7-server-rpms || exit 1
else
 echo "Not Running RHEL 7 !"
fi
grep -q -i "release 8" /etc/redhat-release ; then
 rhel8only=1
echo "RHEL 8 supporting latest release"
sudo subscrition-manager register --auto-attach
sudo subscrition-manager reops --disable "*"
sudo subscrition-manager reops --enable ansible-2.8-for-rhel-8-x86_64-rpms
sudo subscrition-manager reops --enable rhel-8-for-x86_64-appstream-rpms
sudo subscrition-manager reops --enable rhel-8-for-x86_64-baseos-rpms
sudo subscrition-manager reops --enable rhel-8-for-x86_64-supplementary-rpms
sudo subscrition-manager reops --enable rhel-8-for-x86_64-optional-rpms
else
 echo "Not Running RHEL 8 !"
fi


echo " "
echo " "
echo " "
echo "*********************************************************"
echo "ENABLE EPEL FOR A FEW PACKAGES"
echo "*********************************************************"
sudo yum -q list installed epel-release-latest-7 &>/dev/null && echo "epel-release-latest-7 is installed" || sudo yum install -y https://dl.fedoraproject.org/pub/epel/epel-release-latest-7.noarch.rpm --skip-broken
sudo yum-config-manager --enable epel || exit 1
sudo subscription-manager repos --enable=rhel-7-server-extras-rpms || exit 1
sudo yum-config-manager --save --setopt=*.skip_if_unavailable=true
sudo yum clean all
sudo rm -fr /var/cache/yum/*
echo " "
echo " "
echo " "
echo "*********************************************************"
echo "INSTALLING PACKAGES ENABLING SCRIPT TO RUN"
echo "*********************************************************"
sudo yum -q list installed yum-utils &>/dev/null && echo "yum-utils is installed" || sudo yum install -y yum-util* --skip-broken
sudo yum -q list installed gtk2-devel &>/dev/null && echo "gtk2-devel is installed" || sudo yum install -y gtk2-devel --skip-broken
sudo yum -q list installed wget &>/dev/null && echo "wget is installed" || sudo yum install -y wget --skip-broken
sudo yum -q list installed firewalld &>/dev/null && echo "firewalld is installed" || sudo yum install -y firewalld --skip-broken
sudo yum -q list installed ansible &>/dev/null && echo "ansible is installed" || sudo yum install -y ansible --skip-broken 
sudo yum -q list installed gnome-terminal &>/dev/null && echo "gnome-terminal is installed" || sudo yum install -y gnome-terminal --skip-broken
sudo yum -q list installed yum &>/dev/null && echo "yum is installed" || sudo yum install -y yum --skip-broken
sudo yum -q list installed lynx &>/dev/null && echo "lynx is installed" || sudo yum install -y lynx --skip-broken
sudo yum -q list installed perl &>/dev/null && echo "perl is installed" || sudo yum install -y perl --skip-broken
sudo yum -q list installed dialog &>/dev/null && echo "dialog is installed" || sudo yum install -y dialog --skip-broken
sudo yum -q list installed xdialog &>/dev/null && echo "xdialog is installed" || yum localinstall -y xdialog-2.3.1-13.el7.centos.x86_64.rpm --skip-broken
sudo yum -q list installed firefox &>/dev/null && echo "firefox is installed" || yum localinstall -y firefox --skip-broken
sudo yum install -y dconf*
sudo yum-config-manager --disable epel
sudo subscription-manager repos --disable=rhel-7-server-extras-rpms
touch ./SCRIPT
echo " "
}
ls ./SCRIPT
if [ $? -eq 0 ]; then
  echo 'The requirements to run this script have been met, proceeding'
  sleep 5
else
  echo "Installing requirements to run script please stand by"
  SCRIPT
  sleep 5
echo " "
fi


#--------------------------Define Env----------------------------

#configures dialog command for proper environment

if [[ -n $DISPLAY ]]
then
# Assume script running under X:windows
DIALOG=`which Xdialog`
RC=$?
if [[ $RC != 0 ]]
then
DIALOG=`which dialog`
RC=$?
if [[ $RC != 0 ]]
then
echo "Error:: Could not locate suitable dialog command: Please install dialog or if running in a desktop install Xdialog."
exit 1
fi
fi
else
# If Display is not set assume ok to use dialog
DIALOG=`which dialog`
RC=$?
if [[ $RC != 0 ]]
then
echo "Error:: Could not locate suitable dialog command: Please install dialog or if running in a desktop install Xdialog."
exit 1
fi
fi
#------------------------------------------------------SCRIPT BEGINS-----------------------------------------------------
#------------------------------------------------------ Functions ------------------------------------------------------

#-------------------------------
function INSIGHTS {
#-------------------------------
sudo yum update python-requests -y
sudo yum install redhat-access-insights -y
sudo redhat-access-insights --register
}

#-----------------------------------------------------------------------------------------------------------------------
#-------------------------------------------------Ansible Tower---------------------------------------------------------
#-----------------------------------------------------------------------------------------------------------------------
#-------------------------------
function ANSIBLETOWER {
#-------------------------------
source /root/.bashrc
echo -ne "\e[8;33;120t"
reset 

HNAME=$(hostname)
echo " "
echo " "
echo " "
echo " "
echo "
ANSIBLE-TOWER BASE REQUIREMENTS

1. Ansible-Tower will require a license.
Please register and download your lincense at http://www.ansible.com/tower-trial

2. Hardware requirement depends, however whether 
 it is a KVM or physical-Tower will require atleast 1 node with:

Min Storage 35 GB
Directorys Recommended
/Rest of drive
/boot 1024MB
/swap 8192MB

Min RAM 4096
Min CPU2 (4 Reccomended)"
echo " "
echo " "
echo " "
echo " "
echo " "
read -p "Press [Enter] to continue"
echo "

REQUIREMENTS CONTINUED
3. Network
Connection to the internet so the instller can download the required packages

4. For this POC you must have a RHN User ID and password with entitlements
   to channels below. (item 6)

5. Install ansible tgz will be downloaded and placed into the FILES directory created by the sript on the host machine:

* Ansible-Tower download will be pulled from https://releases.ansible.com/awx/setup/ansible-tower-setup-latest.tar.gz

6. This install was tested with:
     * RHEL7 or 8 in a KVM environment.
     * Red Hat subscriber channels:
        rhel-X-server-ansible-2.8-rpms
        rhel-X-server-extras-rpms
        rhel-X-server-optional-rpms
        rhel-X-server-rpms
          https://dl.fedoraproject.org/pub/epel/epel-release-latest-7.noarch.rpm


7. Additional resources, packages, and documentation may be found at
          http://www.ansible.com
          https://www.ansible.com/tower-trial
          http://docs.ansible.com/ansible-tower/latest/html/quickinstall/index.html"
echo " "
echo " "
read -p "If you have met the minimum requirement from above please Press [Enter] to continue"

echo "************************************"
echo "installing prereq"
echo "************************************"
if grep -q -i "release 7" /etc/redhat-release ; then
rhel7only=1
echo "RHEL 7.7"
sudo sudo subscrition-manager register --auto-attach
sudo sudo subscrition-manager reops --disable "*"
sudo sudo subscrition-manager reops --enable rhel-7-server-rpms --enable rhel-server-rhscl-7-rpms --enable rhel-7-server-optional-rpms --enable rhel-7-server-ansible-2.8-rpms
#If in AWS
sudo yum-config-manager --enable epel rhui-REGION-client-config-server-7 rhui-REGION-rhel-server-extras rhui-REGION-rhel-server-releases rhui-REGION-rhel-server-rh-common rhui-REGION-rhel-server-rhscl

sudo yum clean all
sudo rm -rf /var/cache/yum
sudo yum-config-manager --setopt=\*.skip_if_unavailable=1 --save \* 

sudo yum --noplugins -q list installed epel-release-latest-7 &>/dev/null && echo "epel-release-latest-7 is installed" || sudo yum install -y https://dl.fedoraproject.org/pub/epel/epel-release-latest-7.noarch.rpm --skip-broken --noplugins
sudo yum --noplugins -q list installed yum-utils &>/dev/null && echo "yum-utils is installed" || sudo yum install -y yum-utils --skip-broken --noplugins
sudo yum-config-manager --enable epel 
sudo yum --noplugins -q list installed ansible &>/dev/null && echo "ansible is installed" || sudo yum install -y ansible --skip-broken --noplugins
sudo yum --noplugins -q list installed wget &>/dev/null && echo "wget is installed" || sudo yum install -y wget --skip-broken --noplugins
sudo yum --noplugins -q list installed bash-completion-extras &>/dev/null && echo "bash-completion-extras" || sudo yum install -y bash-completion-extras --skip-broken --noplugins
sudo yum --noplugins -q list installed python2-pip &>/dev/null && echo "python2-pip is installed" || sudo yum install -y python2-pip --skip-broken --noplugins
sudo pip install --upgrade pip 
sudo yum-config-manager --disable epel 
echo '************************************'
echo 'Expanding Ansible Tower and installing '
echo '************************************'
wget https://releases.ansible.com/ansible-tower/setup-bundle/ansible-tower-setup-bundle-latest.el7.tar.gz
sudo chown admin:admin ansible-tower-setup-bundle-latest.el7.tar.gz
echo '************************************'
echo 'Expanding Ansible Tower and installing '
echo '************************************'
tar -zxvf ansible-tower-*.tar.gz
cd ansible-tower*
sed -i 's/admin_password="''"/admin_password="'redhat'"/g' inventory
sed -i 's/redis_password="''"/redis_password="'redhat'"/g' inventory
sed -i 's/pg_password="''"/pg_password="'redhat'"/g' inventory
sed -i 's/rabbitmq_password="''"/rabbitmq_password="'redhat'"/g' inventory
sudo ~/Downloads/ansible-tower/setup.sh
sleep 10
echo " "
echo " "
echo " "
echo '************************************'
echo 'Installing Cloud Requirements (Ignore Errors)'
echo '************************************'
sudo source /var/lib/awx/venv/ansible/bin/activate
sudo pip install --upgrade pip 
sudo pip install s3transfer 
sudo pip install s3transfer  --upgrade
sudo pipfreeze | grep s3transfer
sudo pip install boto3 
sudo pip install boto3 
sudo pip install botocore 
sudo pip install botocore --upgrade
sudo pip install boto 
sudo pip install boto --upgrade
sudo pipfreeze | grep boto
echo " "
echo " "
echo " "
sudo pip install six 
sudo pip install six --upgrade
sudo pipfreeze | grep six
echo " "
echo " "
echo " "
sudo pip install awscli 
sudo pip install awscli --upgrade
sudo pipfreeze | grep awscli 
echo " "
echo " "
echo " "
sudo pip install azure 
sudo pip install azure --upgrade
sudo pip install azure-nspkg --upgrade
sudo pip install azure-nspkg --upgrade
for i in $(sudo pipfreeze | grep azure | awk -F '=' '{print $1}') ; do sudo pip install "$i" ; done
for i in $(sudo pipfreeze | grep azure | awk -F '=' '{print $1}') ; do sudo pip install "$i" --upgrade ; done
sudo pip install azure-common 
sudo pip install azure-common --upgrade
sudo pip install azure-mgmt-authorization 
sudo pip install azure-mgmt-authorization --upgrade
sudo pip install azure-mgmt 
sudo pip install azure-mgmt --upgrade
sudo pipfreeze | grep azure
echo " "
echo " "
echo " "
sudo pip install pywinrm 
sudo pip install pywinrm --upgrade
sudo pipfreeze | grep pywinrm
echo " "
echo " "
echo " "
sudo pip install requests 
sudo pip install requests --upgrade
sudo pipfreeze | grep requests
echo " "
echo " "
echo " "
sudo pip install requests-credssp 
sudo pip install requests-credssp --upgrade
sudo pipfreeze | grep requests-credssp

sudo pip install boto --user --upgrade --force-reinstall
sudo pip install boto3 --user --upgrade --force-reinstall
sudo pip install botocore --user --upgrade --force-reinstall

exit
else
reset
echo " "
echo " "
echo " "
echo "Not Running RHEL 7.x ! STAND BY TRYING RHEL 8"
reset
fi

echo '************************************'
echo 'Wget Ansible Tower RHEL 8'
echo '************************************'
if grep -q -i "release 8." /etc/redhat-release ; then
 rhel8only=1
echo "RHEL 8 supporting latest release"
sudo subscrition-manager register --auto-attach
sudo subscrition-manager reops --disable "*"
sudo subscrition-manager reops --enable ansible-2.8-for-rhel-8-x86_64-rpms
sudo subscrition-manager reops --enable rhel-8-for-x86_64-appstream-rpms
sudo subscrition-manager reops --enable rhel-8-for-x86_64-baseos-rpms
sudo subscrition-manager reops --enable rhel-8-for-x86_64-supplementary-rpms
sudo subscrition-manager reops --enable rhel-8-for-x86_64-optional-rpms
sudo yum-config-manager --setopt=\*.skip_if_unavailable=1 --save \* 
sudo yum --noplugins -q list installed epel-release-latest-8 &>/dev/null && echo "epel-release-latest-8 is installed" || sudo yum install -y https://dl.fedoraproject.org/pub/epel/epel-release-latest-8.noarch.rpm --skip-broken --noplugins
sudo yum --noplugins -q list installed dnf-utils &>/dev/null && echo "dnf-utils is installed" || sudo yum install -y dnf-utils --skip-broken --noplugins
sudo yum-config-manager --enable epel
sudo yum clean all
sudo rm -rf /var/cache/yum
sudo yum --noplugins -q list installed ansible &>/dev/null && echo "ansible is installed" || sudo yum install -y ansible --skip-broken --noplugins
sudo yum --noplugins -q list installed wget &>/dev/null && echo "wget is installed" || sudo yum install -y wget --skip-broken --noplugins
sudo yum --noplugins -q list installed bash-completion-extras &>/dev/null && echo "bash-completion-extras" || sudo yum install -y bash-completion-extras --skip-broken --noplugins
sudo yum --noplugins -q list installed python3-pip &>/dev/null && echo "python3-pip" || sudo yum install -y python3-pip --skip-broken --noplugins

sudo yum-config-manager --disable epel
echo '************************************'
echo 'Expanding Ansible Tower and installing '
echo '************************************'
wget https://releases.ansible.com/ansible-tower/setup-bundle/ansible-tower-setup-bundle-latest.el8.tar.gz
sudo chown admin:admin ansible-tower-setup-bundle-latest.el8.tar.gz
echo '************************************'
echo 'Expanding Ansible Tower and installing '
echo '************************************'
tar -zxvf ansible-tower-*.tar.gz
cd ansible-tower*
sed -i 's/admin_password="''"/admin_password="'redhat'"/g' inventory
sed -i 's/redis_password="''"/redis_password="'redhat'"/g' inventory
sed -i 's/pg_password="''"/pg_password="'redhat'"/g' inventory
sed -i 's/rabbitmq_password="''"/rabbitmq_password="'redhat'"/g' inventory
sudo ~/Downloads/ansible-tower/setup.sh
sleep 10
echo " "
echo " "
echo " "
echo '************************************'
echo 'Installing Cloud Requirements (Ignore Errors)'
echo '************************************'
source /var/lib/awx/venv/ansible/bin/activate
sudo pip install --upgrade sudo pip--user
sudo pip install --upgrade pip3 --user
sudo pip3 install six --user
sudo pip3 install six --upgrade --user
pip3 freeze | grep six
echo " "
echo " "
echo " "
sudo pip3 install awscli --user
sudo pip3 install awscli --upgrade --user
pip3 freeze | grep awscli
echo " "
echo " "
echo " "
sudo pip3 install azure-nspkg --user --user
sudo pip3 install azure-nspkg --upgrade --user
for i in $(pip3 freeze | grep azure | awk -F '=' '{print $1}') ; do sudo pip3 install "$i" --upgrade --user ; done
sudo pip3 install azure --user
sudo pip3 install azure --upgrade --user
sudo pip3 install azure-common --user
sudo pip3 install azure-common --upgrade --user
sudo pip3 install azure-mgmt --user
sudo pip3 install azure-mgmt --upgrade --user
sudo pip3 install azure-mgmt-authorization --user
sudo pip3 install azure-mgmt-authorization --upgrade --user
pip3 freeze | grep azure
echo " "
echo " "
echo " "
sudo pip3 install boto --user
sudo pip3 install boto --upgrade --user
sudo pip3 install boto3 --user
sudo pip3 install boto3 --upgrade --user
sudo pip3 install botocore --user
sudo pip3 install botocore --upgrade --user
pip3 freeze | grep boto
echo " "
echo " "
echo " "
sudo pip3 install pywinrm --user
sudo pip3 install pywinrm --upgrade --user
pip3 freeze | grep pywinrm
echo " "
echo " "
echo " "
sudo pip3 install requests --user
sudo pip3 install requests --upgrade --user
pip3 freeze | grep requests
echo " "
echo " "
echo " "
sudo pip3 install requests-credssp --user
sudo pip3 install requests-credssp --upgrade --user
pip3 freeze | grep requests-credssp
exit
sudo pip3 install boto --user --upgrade --force-reinstall
sudo pip3 install boto3 --user --upgrade --force-reinstall
sudo pip3 install botocore --user --upgrade --force-reinstall
else
 echo "Not Running RHEL 8.x !"
fi
}

#----------------------/----End Primary Functions--------------------------

#-----------------------
function dMainMenu {
#-----------------------
$DIALOG --stdout --title "Red Hat Ansible P.O.C. - RHEL 7.X/8.X" --menu "********** Red Hat Tools Menu ********* \n Please choose [1 -> 2]?" 30 90 10 \
1 "INSTALL ANSIBLE" \
}

#----------------------
function dYesNo {
#-----------------------
$DIALOG --title " Prompt " --yesno "$1" 10 80
}

#-----------------------
function dMsgBx {
#-----------------------
$DIALOG --infobox "$1" 10 80
sleep 10
}

#----------------------
function dInptBx {
#----------------------
#Requires 2 mandatory options and 3rd is preset variable 
$DIALOG --title "$1" --inputbox "$2" 20 80 "$3" 
}

#----------------------------------End-Functions-------------------------------
######################
##### MAIN LOGIC #####
######################
#set -o xtrace
reset
# Sets a time value for Xdialog
[[ -z $DISPLAY ]] || TV=3000
$DIALOG --infobox "

**************************************
****  Red Hat  Ansible Installer  ****
**************************************

`hostname`" 20 80 $TV
[[ -z $DISPLAY ]] && sleep 2 

#---------------------------------Menu----------------------------------------
HNAME=$(hostname)
TMPd=FILES/TMP
while true
do
[[ -e "$TMPd" ]] || mkdir -p $TMPd
TmpFi=$(mktemp $TMPd/xcei.XXXXXXX )
dMainMenu > $TmpFi
RC=$?
[[ $RC -ne 0 ]] && break
Flag=$(cat $TmpFi)
case $Flag in
1) dMsgBx "INSTALL ANSIBLE TOWER" \
sleep 10
ANSIBLETOWER
INSIGHTS
;;
2) dMsgBx "*** EXITING - THANK YOU ***"
break
;;
esac

done

exit 0