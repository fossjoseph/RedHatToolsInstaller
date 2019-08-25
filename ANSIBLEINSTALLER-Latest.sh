#!/bin/bash
#POC/Demo
#This Script is for setting up a basic Ansible Tower (latest) with Azure and AWS support.
echo -ne "\e[8;40;170t"
reset

#--------------------------required packages for script to run----------------------------
#------------------
function SCRIPT {
#------------------
HNAME=$(hostname)
DOM="$(hostname -d)"
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
echo "FIRST DISABLE REPOS"
echo "*********************************************************"
subscription-manager repos --disable "*" || exit 1
echo " "
echo " "
echo " "
echo "*********************************************************"
echo "ENABLE PROPER REPOS"
echo "*********************************************************"
subscription-manager repos --enable=rhel-7-server-rpms || exit 1
subscription-manager repos --enable=rhel-7-server-extras-rpms || exit 1
subscription-manager repos --enable=rhel-7-server-optional-rpms || exit 1
subscription-manager repos --enable=rhel-7-server-rpms || exit 1
echo " "
echo " "
echo " "
echo "*********************************************************"
echo "ENABLE EPEL FOR A FEW PACKAGES"
echo "*********************************************************"
yum -q list installed epel-release-latest-7 &>/dev/null && echo "epel-release-latest-7 is installed" || yum install -y https://dl.fedoraproject.org/pub/epel/epel-release-latest-7.noarch.rpm --skip-broken
yum-config-manager --enable epel  || exit 1
subscription-manager repos --enable=rhel-7-server-extras-rpms || exit 1
yum-config-manager --save --setopt=*.skip_if_unavailable=true
yum clean all
rm -fr /var/cache/yum/*
echo " "
echo " "
echo " "
echo "*********************************************************"
echo "INSTALLING PACKAGES ENABLING SCRIPT TO RUN"
echo "*********************************************************"
yum -q list installed yum-utils &>/dev/null && echo "yum-utils is installed" || yum install -y yum-util* --skip-broken
yum -q list installed gtk2-devel &>/dev/null && echo "gtk2-devel is installed" || yum install -y gtk2-devel --skip-broken
yum -q list installed wget &>/dev/null && echo "wget is installed" || yum install -y wget --skip-broken
yum -q list installed firewalld &>/dev/null && echo "firewalld is installed" || yum install -y firewalld --skip-broken
yum -q list installed ansible &>/dev/null && echo "ansible is installed" || yum install -y ansible --skip-broken 
yum -q list installed gnome-terminal &>/dev/null && echo "gnome-terminal is installed" || yum install -y gnome-terminal --skip-broken
yum -q list installed yum &>/dev/null && echo "yum is installed" || yum install -y yum --skip-broken
yum -q list installed lynx &>/dev/null && echo "lynx is installed" || yum install -y lynx --skip-broken
yum -q list installed perl &>/dev/null && echo "perl is installed" || yum install -y perl --skip-broken
yum -q list installed dialog &>/dev/null && echo "dialog is installed" || yum install -y dialog --skip-broken
yum -q list installed xdialog &>/dev/null && echo "xdialog is installed" || yum localinstall -y xdialog-2.3.1-13.el7.centos.x86_64.rpm --skip-broken
yum -q list installed firefox &>/dev/null && echo "firefox is installed" || yum localinstall -y firefox --skip-broken
yum install -y dconf*
yum-config-manager --disable epel
subscription-manager repos --disable=rhel-7-server-extras-rpms
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
yum update python-requests -y
yum install redhat-access-insights -y
redhat-access-insights --register
}

#-----------------------------------------------------------------------------------------------------------------------
#-------------------------------------------------Ansible Tower---------------------------------------------------------
#-----------------------------------------------------------------------------------------------------------------------
#-------------------------------
#-------------------------------
function ANSIBLETOWER {
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
Directorys  Recommended
/Rest of drive
/boot  1024MB
/swap  8192MB

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
          * RHEL_7.7 in a KVM environment.
          * Red Hat subscriber channels:
             rhel-7-server-ansible-2.8-rpms
             rhel-7-server-extras-rpms
             rhel-7-server-optional-rpms
             rhel-7-server-rpms
             https://dl.fedoraproject.org/pub/epel/epel-release-latest-7.noarch.rpm


7. Additional resources, packages, and documentation may be found at
                    http://www.ansible.com
                    https://www.ansible.com/tower-trial
                    http://docs.ansible.com/ansible-tower/latest/html/quickinstall/index.html"
echo " "
echo " "
read -p "If you have met the minimum requirement from above please Press [Enter] to continue"

#!/bin/bash
echo "************************************"
echo "installing prereq"
echo "************************************"
if grep -q -i "release 7" /etc/redhat-release ; then
rhel7only=1
echo "RHEL 7.7"
subscrition-manager register --auto-attach
subscrition-manager reops --disable "*"
subscrition-manager reops --enable rhel-7-server-rpms
subscrition-manager reops --enable rhel-server-rhscl-7-rpms
subscrition-manager reops --enable rhel-7-server-optional-rpms
subscrition-manager reops --enable --enable rhel-7-server-ansible-2.8-rpms
yum clean all
rm -rf /var/cache/yum
yum-config-manager --setopt=\*.skip_if_unavailable=1 --save \* 

yum --noplugins -q list installed epel-release-latest-7 &>/dev/null && echo "epel-release-latest-7 is installed" || yum install -y https://dl.fedoraproject.org/pub/epel/epel-release-latest-7.noarch.rpm --skip-broken --noplugins
yum --noplugins -q list installed yum-utils &>/dev/null && echo "yum-utils is installed" || yum install -y yum-utils --skip-broken --noplugins
yum-config-manager --enable epel 
yum --noplugins -q list installed ansible &>/dev/null && echo "ansible is installed" || yum install -y ansible --skip-broken --noplugins
yum --noplugins -q list installed wget &>/dev/null && echo "wget is installed" || yum install -y wget --skip-broken --noplugins
yum --noplugins -q list installed bash-completion-extras &>/dev/null && echo "bash-completion-extras" || yum install -y bash-completion-extras --skip-broken --noplugins
yum --noplugins -q list installed python2-pip &>/dev/null && echo "python2-pip is installed" || yum install -y python2-pip --skip-broken --noplugins
yum-config-manager --disable epel 
echo '************************************'
echo 'Expanding Ansible Tower and installing '
echo '************************************'
wget https://releases.ansible.com/ansible-tower/setup-bundle/ansible-tower-setup-bundle-latest.el8.tar.gz
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
pip install --upgrade pip
pip install six
pip install six --upgrade
pip freeze | grep six
echo " "
echo " "
echo " "
pip install awscli
pip install awscli --upgrade 
pip freeze | grep awscli
echo " "
echo " "
echo " "
for i in $(pip freeze | grep azure | awk -F '=' '{print $1}') ; do pip install "$i" --upgrade  ; done
pip install azure
pip install azure  --upgrade
pip install azure-common
pip install azure-common --upgrade
pip install azure-mgmt-authorization
pip install azure-mgmt-authorization --upgrade
pip install azure-mgmt
pip install azure-mgmt --upgrade 
pip freeze | grep azure
echo " "
echo " "
echo " "
pip install boto
pip install boto --upgrade 
pip install boto3
pip install boto3 --upgrade 
pip install botocore
pip install botocore --upgrade
pip freeze | grep boto
echo " "
echo " "
echo " "
pip install pywinrm
pip install pywinrm --upgrade
pip freeze | grep pywinrm
echo " "
echo " "
echo " "
pip install requests
pip install requests --upgrade
pip freeze | grep requests
echo " "
echo " "
echo " "
pip install requests-credssp
pip install requests-credssp --upgrade
pip freeze | grep requests-credssp


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
subscrition-manager register --auto-attach
subscrition-manager reops --disable "*"
subscrition-manager reops --enable ansible-2.8-for-rhel-8-x86_64-rpms
subscrition-manager reops --enable rhel-8-for-x86_64-appstream-rpms
subscrition-manager reops --enable rhel-8-for-x86_64-baseos-rpms
subscrition-manager reops --enable rhel-8-for-x86_64-supplementary-rpms
subscrition-manager reops --enable rhel-8-for-x86_64-optional-rpms
yum-config-manager --setopt=\*.skip_if_unavailable=1 --save \* 
yum --noplugins -q list installed epel-release-latest-8 &>/dev/null && echo "epel-release-latest-8 is installed" || yum install -y https://dl.fedoraproject.org/pub/epel/epel-release-latest-8.noarch.rpm --skip-broken --noplugins
yum --noplugins -q list installed dnf-utils &>/dev/null && echo "dnf-utils is installed" || yum install -y dnf-utils --skip-broken --noplugins
yum-config-manager --enable epel 
yum clean all
rm -rf /var/cache/yum
yum --noplugins -q list installed ansible &>/dev/null && echo "ansible is installed" || yum install -y ansible --skip-broken --noplugins
yum --noplugins -q list installed wget &>/dev/null && echo "wget is installed" || yum install -y wget --skip-broken --noplugins
yum --noplugins -q list installed bash-completion-extras &>/dev/null && echo "bash-completion-extras" || yum install -y bash-completion-extras --skip-broken --noplugins
yum --noplugins -q list installed python3-pip &>/dev/null && echo "python3-pip" || yum install -y python3-pip --skip-broken --noplugins

yum-config-manager --disable epel
echo '************************************'
echo 'Expanding Ansible Tower and installing '
echo '************************************'
wget https://releases.ansible.com/ansible-tower/setup-bundle/ansible-tower-setup-bundle-latest.el8.tar.gz
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
pip install --upgrade pip
pip install --upgrade pip3
pip3 install six
pip3 install six --upgrade
pip3 freeze | grep six
echo " "
echo " "
echo " "
pip3 install awscli
pip3 install awscli --upgrade 
pip3 freeze | grep awscli
echo " "
echo " "
echo " "
for i in $(pip3 freeze | grep azure | awk -F '=' '{print $1}') ; do pip3 install "$i" --upgrade  ; done
pip3 install azure
pip3 install azure  --upgrade
pip3 install azure-common
pip3 install azure-common --upgrade
pip3 install azure-mgmt-authorization
pip3 install azure-mgmt-authorization --upgrade
pip3 install azure-mgmt
pip3 install azure-mgmt --upgrade 
pip3 freeze | grep azure
echo " "
echo " "
echo " "
pip3 install boto
pip3 install boto --upgrade 
pip3 install boto3
pip3 install boto3 --upgrade 
pip3 install botocore
pip3 install botocore --upgrade
pip3 freeze | grep boto
echo " "
echo " "
echo " "
pip3 install pywinrm
pip3 install pywinrm --upgrade
pip3 freeze | grep pywinrm
echo " "
echo " "
echo " "
pip3 install requests
pip3 install requests --upgrade
pip3 freeze | grep requests
echo " "
echo " "
echo " "
pip3 install requests-credssp
pip3 install requests-credssp --upgrade
pip3 freeze | grep requests-credssp
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
#### MAIN LOGIC ####
######################
#set -o xtrace
clear
# Sets a time value for Xdialog
[[ -z $DISPLAY ]] || TV=3000
$DIALOG --infobox "

**************************
**** Red Hat - Config Tools****
**************************

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
1) dMsgBx "INSTALL SATELLITE 6.5" \
sleep 10
ANSIBLETOWER
;;
2) dMsgBx "*** EXITING - THANK YOU ***"
break
;;
esac

done

exit 0