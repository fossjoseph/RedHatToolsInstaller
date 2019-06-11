#!/bin/bash
#POC/Demo
echo -ne "\e[8;40;170t"

# https://github.com/ShaddGallegos/RedHatToolsInstaller.git
#
# Hammer referance to assist in modifing the script can be found at 
# https://www.gitbook.com/book/abradshaw/getting-started-with-satellite-6-command-line/details


reset

#--------------------------required packages for script to run----------------------------

echo " "
echo " "
echo " "
echo " "
echo " "
echo " "
echo " "
echo " "
echo " "
echo "

                           P.O.C Satellite 6.X RHEL 7.X KVM or RHEL 7 Physical Host 
                              THIS SCRIPT CONTAINS NO CONFIDENTIAL INFORMATION

                  This script is designed to set up a basic standalone Satellite 6.X system

             Disclaimer: This script was written for education, evaluation, and/or testing purposes. 
    This helper script is Licensed under GPL and there is no implied warranty and is not officially supported by anyone.
                                 
         ...SHOULD NOT BE USED ON A CURRENTlY OPERATING PRODUCTION SYSTEM - USE AT YOUR OWN RISK...
         Satellite 6.4 requirements can be found at 


   However the if you have an issue with the products installed and have a valid License please contact Red Hat at:

   RED HAT Inc..
   1-888-REDHAT-1 or 1-919-754-3700, then select the Menu Prompt for Customer Service
   Spanish: 1-888-REDHAT-1 Option 5 or 1-919-754-3700 Option 5
   Fax: 919-754-3701 (General Corporate Fax)
   Email address: customerservice@redhat.com "

echo " "
echo " "
echo " "
echo " "
echo " "
echo " "
echo " "
echo " "
echo " "
echo " "
echo " "
echo " "
echo " "
echo " "
echo " "
read -p "Press [Enter] to continue"
clear
echo " "
echo " "
echo " "
echo " "
echo " "
echo " "
echo " "
echo " "
echo " "
echo "
                          JUST A REVIEW
                          This is a Proof Of Concept script for the purposes of evaluation
                          and/or training.
                          Requirements for this script to work:
                           * RHEL 7.6 Base install or Server with UI
                           * A Baremetal or VM (Snap shot this system in case you want 
                             to change something and run again)
                           * System
                              4 PROC
                              22 GB RAM
                              250 GB Storage
                           * Basic Partitioning on LVM 
                              /  (root) 
                              /boot
                              swap 

                           If this is more than a Proof of Concept please vist: 
                            https://access.redhat.com/documentation/en-us/red_hat_satellite/6.4/html/installing_satellite_server_from_a_connected_network/preparing_your_environment_for_installation#hardware_storage_prerequisites

                           * An external network connection 
                           * A subscription to Satellite 
                              In another window you will need to obtain your account Satellite pool ID from: 
                              ' subscription-manager list --available ' save that incase you are prompted for the it
                           * Manifest created with some entitlements and downloaded from:
                            https://access.redhat.com/management/subscription_allocations/
                           * The manifest should be placed in the directory /home/admin/Downloads
                           * Lastly this script 
                               "


echo " "
echo " "
echo " "
echo " "
echo " "
read -p "Press [Enter] to continue"
clear
if [ "$(whoami)" != "root" ]
then
echo "This script must be run as root - if you do not have the credentials please contact your administrator"
exit
fi

#--------------------------required packages for script to run----------------------------
#------------------
function SCRIPT {
#------------------
echo ""
echo "*************************************************************"
echo " Script configuration requirements installing for this server"
echo "*************************************************************"
echo "*********************************************************"
echo "SET SELINUX TO PERMISSIVE FOR THE INSTALL AND CONFIG OF SATELLITE"
echo "*********************************************************"
sed -i 's/SELINUX=enforcing/SELINUX=permissive/g' /etc/selinux/config
setenforce 0
service firewalld stop
chkconfig firewalld off
HNAME=$(hostname)
DOM="$(hostname -d)"
mkdir -p /home/admin/Downloads
echo ""
echo "*********************************************************"
echo "UNREGESTERING SYSTEM"
echo "*********************************************************"
echo "To ensure the system has proper entitlements and the ability to enable required repos"
read -p "Press [Enter] to continue"
subscription-manager unregister
subscription-manager clean
echo " "
echo "*********************************************************"
echo "REGESTERING SYSTEM"
echo "*********************************************************"
subscription-manager register
echo " "
echo "*********************************************************"
echo "NOTE:"
echo "*********************************************************"
echo "Attaching to your Satellite subscription using the pool id if the predefined value fails please
obtain your pool id in another terminal running:

subscription-manager list --available
 or 
subscription-manager list --available --matches 'Red Hat Satellite'

"
echo " "
read -p "Press [Enter] 32 digit pool id if prompted "
echo " "
subscription-manager attach --pool=`subscription-manager list --available --matches 'Red Hat Satellite Infrastructure Subscription' --pool-only`
if [ $? -eq 0 ]; then
    echo 'Attaching Red Hat Satellite Infrastructure Subscription'
else
echo 'None of the predefined Satellite Pool IDs worked please enter your 32 digit alphanumeric Pool ID'
read POOLID
subscription-manager attach --pool=`$POOLID` || exit 1
echo " "
fi
echo " "
echo "*********************************************************"
echo "SET REPOS ENABLING THE REDHATTOOLSINSTALLER SCRIPT TO RUN"
echo "*********************************************************"
subscription-manager repos --disable "*" || exit 1
subscription-manager repos --enable=rhel-7-server-rpms || exit 1
subscription-manager repos --enable=rhel-7-server-extras-rpms || exit 1
subscription-manager repos --enable=rhel-7-server-optional-rpms || exit 1
yum -q list installed epel-release-latest-7 &>/dev/null && echo "epel-release-latest-7 is installed" || yum install -y https://dl.fedoraproject.org/pub/epel/epel-release-latest-7.noarch.rpm --skip-broken
yum -q list installed yum-utils &>/dev/null && echo "yum-utils is installed" || yum install -y yum-util* --skip-broken
yum-config-manager --enable epel 
yum-config-manager --save --setopt=*.skip_if_unavailable=true
rm -fr /var/cache/yum/*
yum clean all
echo " "
echo "*********************************************************"
echo "INSTALLING PACKAGES ENABLING SCRIPT TO RUN"
echo "*********************************************************"
yum -q list installed gtk2-devel &>/dev/null && echo "gtk2-devel is installed" || yum install -y gtk2-devel --skip-broken
yum -q list installed wget &>/dev/null && echo "wget is installed" || yum install -y wget --skip-broken
yum -q list installed firewalld &>/dev/null && echo "firewalld is installed" || yum install -y firewalld --skip-broken
yum -q list installed ansible &>/dev/null && echo "ansible is installed" || yum install -y ansible --skip-broken 
yum -q list installed gnome-terminal &>/dev/null && echo "gnome-terminal is installed" || yum install -y gnome-terminal --skip-broken
yum -q list installed yum &>/dev/null && echo "yum is installed" || yum install -y yum --skip-broken
yum -q list installed perl &>/dev/null && echo "perl is installed" || yum install -y perl --skip-broken
yum -q list installed dialog &>/dev/null && echo "dialog is installed" || yum install -y dialog --skip-broken
yum -q list installed xdialog &>/dev/null && echo "xdialog is installed" || yum localinstall -y xdialog-2.3.1-13.el7.centos.x86_64.rpm --skip-broken
yum -q list installed firefox &>/dev/null && echo "firefox is installed" || install -y firefox --skip-broken
yum -q list installed libpwquality &>/dev/null && echo "libpwquality is installed" || install -y libpwquality --skip-broken
yum install -y dconf*
touch ./SCRIPT
echo " "
}
ls ./SCRIPT
if [ $? -eq 0 ]; then
    echo 'The requirements to run this script have been met, proceeding'
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
subscription-manager unregister
subscription manager clean
exit 1
fi
fi
else
# If Display is no set assume ok to use dialog
DIALOG=`which dialog`
RC=$?
if [[ $RC != 0 ]]
then
echo "Error:: Could not locate suitable dialog command: Please install dialog or if running in a desktop install Xdialog."
subscription-manager unregister
subscription manager clean
exit 1
fi
fi
#------------------------------------------------------SCRIPT BEGINS-----------------------------------------------------
#------------------------------------------------------ Functions ------------------------------------------------------
#-----------------------------------------------------------------------------------------------------------------------
#-------------------------------
function VARIABLES1 {
#-------------------------------
echo ""
echo "*********************************************************"
echo "COLLECT VARIABLES FOR SAT 6.X"
echo "*********************************************************"
cp -p /root/.bashrc /root/.bashrc.bak
export INTERNAL=$(ip -o link | head -n 2 | tail -n 1 | awk '{print $2}' | sed s/:// )
export EXTERNAL=$(ip route show | sed -e 's/^default via [0-9.]* dev \(\w\+\).*/\1/' | head -1)
export INTERNALIP=$(ifconfig "$INTERNAL" | grep "inet" | awk -F ' ' '{print $2}' |grep -v f |awk -F . '{print $1"."$2"."$3"."$4}')
export INTERNALSUBMASK=$(ifconfig "$INTERNAL" |grep netmask |awk -F " " {'print $4'})
export INTERNALGATEWAY=$(ip route list type unicast dev $(ip -o link | head -n 2 | tail -n 1 | awk '{print $2;}' | sed s/:$//) |awk -F " " '{print $7}')
echo "INTERNALIP=$INTERNALIP" >> /root/.bashrc
echo ""
echo "*********************************************************"
echo "ORGANIZATION"
echo "*********************************************************"
echo 'What is the name of your Organization?'
read ORG
echo 'ORG='$ORG'' >> /root/.bashrc
echo ""
echo "*********************************************************"
echo "LOCATION OF YOUR SATELLITE"
echo "*********************************************************"
echo 'LOCATION'
echo 'What is the location of your Satellite server. Example DENVER'
read LOC
echo 'LOC='$LOC'' >> /root/.bashrc
echo ""
echo "*********************************************************"
echo "SETTING DOMAIN"
echo "*********************************************************"
echo 'what is your domain name Example:'$(hostname -d)''
read DOM
echo 'DOM='$DOM'' >> /root/.bashrc
echo ""
echo "*********************************************************"
echo "ADMIN PASSWORD - WRITE OR REMEMBER YOU WILL BE PROMPTED FOR 
USER: admin AND THIS PASSWORD WHEN WE IMPORT THE MANIFEST"
echo "*********************************************************"
sleep 5
echo 'ADMIN=admin'  >> /root/.bashrc
echo 'What will the password be for your admin user?'
read  ADMIN_PASSWORD
echo 'ADMIN_PASSWORD='$ADMIN_PASSWORD'' >> /root/.bashrc
echo ""
echo "*********************************************************"
echo "NAME OF FIRST SUBNET"
echo "*********************************************************"
echo 'What would you like to call your first subnet for systems you are regestering to satellite?'
read  SUBNET
echo 'SUBNET_NAME='$SUBNET'' >> /root/.bashrc
echo ""
echo "*********************************************************"
echo "PROVISIONED NODE PREFIX"
echo "*********************************************************"
# The host prefix is used to distinguish the demo hosts created at the end of this script.
echo 'What would you like the prefix to be for systems you are provisioning with Satellite Example poc- kvm- vm-? enter to skip'
read  PREFIX
echo 'HOST_PREFIX='$PREFIX'' >> /root/.bashrc
echo ""
echo "*********************************************************"
echo "NODE PASSWORD"
echo "*********************************************************"
echo 'PROVISIONED HOST PASSWORD'
echo 'Please enter the default password you would like to use for root for your newly provisioned nodes'
read PASSWORD
for i in $(echo "$PASSWORD" | openssl passwd -apr1 -stdin); do echo NODEPASS=$i >> /root/.bashrc ; done

export "DHCPSTART=$(ifconfig $INTERNAL | grep "inet" | awk -F ' ' '{print $2}' |grep -v f |awk -F . '{print $1"."$2"."$3"."2}')"
export "DHCPEND=$(ifconfig $INTERNAL | grep "inet" | awk -F ' ' '{print $2}' |grep -v f |awk -F . '{print $1"."$2"."$3"."254}')"
echo ""
echo "*********************************************************"
echo "FINDING NETWORK"
echo "*********************************************************"
echo 'INTERNALNETWORK='$(ifconfig "$INTERNAL" | grep "inet" | awk -F ' ' '{print $2}' |grep -v f |awk -F . '{print $1"."$2"."0"."0}')'' >> /root/.bashrc
echo ""
echo "*********************************************************"
echo "FINDING SAT INTERFACE"
echo "*********************************************************"
echo 'SAT_INTERFACE='$(ip -o link | head -n 2 | tail -n 1 | awk '{print $2;}' | sed s/:$//)'' >> /root/.bashrc
echo ""
echo "*********************************************************"
echo "FINDING SAT IP"
echo ""
echo "*********************************************************"
echo 'SAT_IP='$(ifconfig "$INTERNAL" | grep "inet" | awk -F ' ' '{print $2}' |grep -v f |awk -F . '{print $1"."$2"."$3"."$4}')'' >> /root/.bashrc
echo ""
echo "*********************************************************"
echo "SETTING RELM"
echo "*********************************************************"
echo 'REALM='$(hostname -d)'' >> /root/.bashrc
echo ""
echo "*********************************************************"
echo "SETTING DNS"
echo "*********************************************************"
echo 'DNS='$(ip route list type unicast dev $(ip -o link | head -n 2 | tail -n 1 | awk '{print $2;}' | sed s/:$//) |awk -F " " '{print $7}')'' >> /root/.bashrc
echo 'DNS_REV='$(ifconfig $INTERNAL | grep "inet" | awk -F ' ' '{print $2}' |grep -v f |awk -F . '{print $3"."$2"."$1".""in-addr.arpa"}')'' >> /root/.bashrc
echo ""
echo "*********************************************************"
echo "DNS PTR RECORD"
echo "*********************************************************"
'PTR='$(ifconfig "$INTERNAL" | grep "inet" | awk -F ' ' '{print $2}' |grep -v f |awk -F . '{print $4}')''  >> /root/.bashrc
echo ""
echo "*********************************************************"
echo "SETTING SUBNET VARS"
echo "*********************************************************"
echo 'SUBNET='$(ifconfig $INTERNAL | grep "inet" | awk -F ' ' '{print $2}' |grep -v f |awk -F . '{print $1"."$2"."0"."0}')'' >> /root/.bashrc
echo 'SUBNET_MASK='$(ifconfig $INTERNAL |grep netmask |awk -F " " {'print $4'})'' >> /root/.bashrc
echo ""
echo "*********************************************************"
echo "SETTING BGIN AND END IPAM RANGE"
echo "*********************************************************"
echo 'SETTING BEGIN AND END IPAM RANGE'
echo 'SUBNET_IPAM_BEGIN='$DHCPSTART'' >> /root/.bashrc
echo 'SUBNET_IPAM_END='$DHCPEND'' >> /root/.bashrc
echo ""
echo "*********************************************************"
echo "DHCP"
echo "*********************************************************"
echo 'DHCP_RANGE=''"'$DHCPSTART' '$DHCPEND'"''' >> /root/.bashrc
echo 'DHCP_GW='$(ip route list type unicast dev $(ip -o link | head -n 2 | tail -n 1 | awk '{print $2;}' | sed s/:$//) |awk -F " " '{print $7}')'' >> /root/.bashrc
echo 'DHCP_DNS='$(ifconfig $INTERNAL | grep "inet" | awk -F ' ' '{print $2}' |grep -v f |awk -F . '{print $1"."$2"."$3"."$4}')'' >> /root/.bashrc
echo ""
}

YMESSAGE="Adding to /root/.bashrc vars"
NMESSAGE="Skipping"
FMESSAGE="PLEASE ENTER Y or N"
DEFAULTVALUE=n
#-------------------------------
function IPA {
#-------------------------------
echo ""
echo "*********************************************************"
echo "IPA SERVER"
echo "*********************************************************"
read -n1 -p "Do you have an IPA server? Y/N " INPUT
INPUT=${INPUT:-$DEFAULTVALUE}
if  [ "$INPUT" = "y" -o "$INPUT" = "Y" ] ;then
echo -e "\n$YMESSAGE\n"
yum install -y ipa-client ipa-admintools
echo 'What is the FQDN of the IPA Server?'
read  FQDNIPA
echo 'IPA_SERVER='$FQDNIPA'' >> /root/.bashrc
echo 'What is the location of the Capsule?'
echo 'What is the ip address of your IPA host?'
read  IPAIP
echo 'IPA_IP='$IPAIP'' >> /root/.bashrc
source /root/.bashrc
echo '$IPA_IP $FQDNIPA' >> /etc/hosts
#COMMANDEXECUTION
elif [ "$INPUT" = "n" -o "$INPUT" = "N" ] ;then
echo -e "\n$NMESSAGE\n"
#COMMANDEXECUTION
else
echo -e "\n$FMESSAGE\n"
REQUEST
fi
}
#-------------------------------
function CAPSULE {
#-------------------------------
echo ""
echo "*********************************************************"
echo "CAPSULE"
echo "*********************************************************"
read -n1 -p "Would you like to install a secondary capsule ? Y/N " INPUT
INPUT=${INPUT:-$DEFAULTVALUE}
if  [ "$INPUT" = "y" -o "$INPUT" = "Y" ] ;then
echo -e "\n$YMESSAGE\n"
echo 'PREPARE_CAPSULE=true' >> /root/.bashrc
echo 'What will the FQDN of the Capsule be?'
read CAPNAME
echo 'CAPSULE_NAME='$CAPNAME'' >> /root/.bashrc
echo 'What is the location of the Capsule?'
read CAPLOC
echo 'CAPSULE_LOC='$CAPLOC'' >> /root/.bashrc
#COMMANDEXECUTION
elif  [ "$INPUT" = "n" -o "$INPUT" = "N" ] ;then
echo -e "\n$NMESSAGE\n"
#COMMANDEXECUTION
else
echo -e "\n$FMESSAGE\n"
REQUEST
fi
}
#-------------------------------
function SATLIBVIRT {
#-------------------------------
echo ""
echo "*********************************************************"
echo "LIBVIRT COMPUTE RESOURCE"
echo "*********************************************************"
read -n1 -p "Would you like to set up LIBVIRT as a compute resourse ? Y/N " INPUT
INPUT=${INPUT:-$DEFAULTVALUE}
if  [ "$INPUT" = "y" -o "$INPUT" = "Y" ] ;then
echo -e "\n$YMESSAGE\n"
echo 'CONFIGURE_LIBVIRT_RESOURCE=true' >> /root/.bashrc
echo 'What is the fqdn of your libvirt host?'
read  LIBVIRTFQDN
echo 'COMPUTE_RES_FQDN='$LIBVIRTFQDN'' >> /root/.bashrc
echo 'What is the ip address of your libvirt host?'
read  LIBVIRTIP
echo 'COMPUTE_RES_IP='$LIBVIRTIP'' >> /root/.bashrc
echo 'What would you like to name your libvirt satellite resource? Example KVM'
read  KVM
echo 'COMPUTE_RES_NAME='$KVM'' >> /root/.bashrc
source /root/.bashrc
echo ''$COMPUTE_RES_IP' '$COMPUTE_RES_FQDN'' >> /etc/hosts
#COMMANDEXECUTION
elif [ "$INPUT" = "n" -o "$INPUT" = "N" ] ;then
echo -e "\n$NMESSAGE\n"
echo 'CONFIGURE_LIBVIRT_RESOURCE=false' >> /root/.bashrc
#COMMANDEXECUTION
else
echo -e "\n$FMESSAGE\n"
REQUEST
fi
}
#-------------------------------
function SATRHV {
#-------------------------------
echo ""
echo "*********************************************************"
echo "RHV COMPUTE RESOURCE"
echo "*********************************************************"
read -n1 -p "Would you like to set up RHV as a compute resourse ? Y/N " INPUT
INPUT=${INPUT:-$DEFAULTVALUE}
if  [ "$INPUT" = "y" -o "$INPUT" = "Y" ] ;then
echo -e "\n$YMESSAGE\n"
echo 'CONFIGURE_RHEV_RESOURCE=true' >> /root/.bashrc
echo 'What is the fqdn of your RHV host?'
read  RHVQDN
echo 'COMPUTE_RES_FQDN=$RHVFQDN' >> /root/.bashrc
echo 'What is the ip address of your RHV host?'
read  RHVIP
echo 'COMPUTE_RES_IP=$RHVIP' >> /root/.bashrc
echo 'What would you like to name your RHV satellite resource? Example RHV'
read  RHV
echo 'COMPUTE_RES_NAME=$RHV' >> /root/.bashrc
echo 'RHV_VERSION_4=true' >> /root/.bashrc
echo 'RHV_RES_USER=admin@internal' >> /root/.bashrc
echo 'RHV_RES_PASSWD='$ADMIN_PASSWORD'' >> /root/.bashrc
echo 'RHV_RES_UUID=Default' >> /root/.bashrc
source /root/.bashrc
echo '$COMPUTE_RES_IP " " $COMPUTE_RES_FQDN' >> /etc/hosts
#COMMANDEXECUTION
elif [ "$INPUT" = "n" -o "$INPUT" = "N" ] ;then
echo -e "\n$NMESSAGE\n"
echo 'CONFIGURE_RHEV_RESOURCE=false' >> /root/.bashrc
#COMMANDEXECUTION
else
echo -e "\n$FMESSAGE\n"
REQUEST
fi
}
# This script alternatively allows to use a RHV virtualization backend using the following parameters
#-------------------------------
function RHVORLIBVIRT {
#-------------------------------
echo " "
echo "*********************************************************"
echo "RHV or LIBVIRT=TRUE"
echo "*********************************************************"
source /root/.bashrc
if [ $CONFIGURE_RHEV_RESOURCE = 'true' -a $CONFIGURE_LIBVIRT_RESOURCE = 'true' ]; then
echo "Only one of CONFIGURE_RHEV_RESOURCE and CONFIGURE_LIBVIRT_RESOURCE may be true."
exit 1
fi
# FIRST_SATELLITE matters only if you want to have more than one Sat work with the same IPAREALM infrastructure.
# If this is the case, you need to make sure to set this to false for all subsequent Satellite instances.
echo 'FIRST_SATELLITE=false ' >> /root/.bashrc
echo ' '
echo 'In another terminal please check/correct any variables in /root/.bashrc
that are not needed or are wrong'
read -p "Press [Enter] to continue"
}
#-------------------------------
function DEFAULTMSG {
#-------------------------------
echo ""
echo "*********************************************************"
echo "BY DEFAULT IF YOU JUST LET THIS SCRIPT RUN YOU WILL 
ONLY SYNC THE CORE RHEL 7 (KICKSTART, 7SERVER, OPTIONAL, EXTRAS,
 SAT 6.4 TOOLS, SUPPLAMENTRY, AND RH COMMON ) THE PROGRESS 
 TO THIS STEP CAN BE TRACKED AT $(hostname)/katello/sync_management:"
echo "*********************************************************"
echo " "
}
#-------------------------------
function SYNCREL5 {
#-------------------------------
echo " "
echo "*********************************************************"
echo "SYNC RHEL 5?"
echo "*********************************************************"
read -n1 -p "Would you like to enable RHEL 5 content  ? Y/N" INPUT
INPUT=${INPUT:-$RHEL5DEFAULTVALUE}
if  [ "$INPUT" = "y" -o "$INPUT" = "Y" ] ;then
echo -e "\n$YMESSAGE\n"
echo 'RHEL5DEFAULTVALUE=y' >> /root/.bashrc
#COMMANDEXECUTION
elif  [ "$INPUT" = "n" -o "$INPUT" = "N" ] ;then
echo -e "\n$NMESSAGE\n"
echo 'RHEL5DEFAULTVALUE=n' >> /root/.bashrc
#COMMANDEXECUTION
else
echo -e "\n$FMESSAGE\n"
REQUEST
fi
}
#-------------------------------
function SYNCREL6 {
#-------------------------------
echo " "
echo "*********************************************************"
echo "SYNC RHEL 6?"
echo "*********************************************************"
read -n1 -p "Would you like to enable RHEL 6 content  ? Y/N" INPUT
INPUT=${INPUT:-$RHEL6DEFAULTVALUE}
if  [ "$INPUT" = "y" -o "$INPUT" = "Y" ] ;then
echo -e "\n$YMESSAGE\n"
echo 'RHEL6DEFAULTVALUE=y' >> /root/.bashrc
#COMMANDEXECUTION
elif  [ "$INPUT" = "n" -o "$INPUT" = "N" ] ;then
echo -e "\n$NMESSAGE\n"
echo 'RHEL6DEFAULTVALUE=n' >> /root/.bashrc
#COMMANDEXECUTION
else
echo -e "\n$FMESSAGE\n"
REQUEST
fi
}
#---END OF VARIABLES 1 SCRIPT---

#---START OF SAT 6.X INSTALL SCRIPT---
#------------------------------
function INSTALLREPOS {
#------------------------------
echo " "
echo "*********************************************************"
echo "SETTING REPOS FOR INSTALLING AND UPDATING SATELLITE 6.4"
echo "*********************************************************"
echo -ne "\e[8;40;170t"
subscription-manager repos --disable '*'
yum-config-manager --disable epel
subscription-manager repos --enable=rhel-7-server-rpms || exit 1
subscription-manager repos --enable=rhel-server-rhscl-7-rpms || exit 1
subscription-manager repos --enable=rhel-7-server-optional-rpms || exit 1
subscription-manager repos --enable=rhel-7-server-satellite-6.4-rpms || exit 1
subscription-manager repos --enable=rhel-7-server-satellite-maintenance-6-rpms || exit 1
yum clean all 
rm -rf /var/cache/yum
}
#------------------------------
function INSTALLDEPS {
#------------------------------
echo ""
echo "*********************************************************"
echo "INSTALLING DEPENDENCIES FOR SATELLITE OPERATING ENVIRONMENT"
echo "*********************************************************"
echo -ne "\e[8;40;170t"
yum-config-manager --enable epel
sleep 5
yum install -y rh-mongodb34 rh-mongodb34-syspaths screen yum-utils vim gcc gcc-c++ git rh-nodejs8-npm make automake kernel-devel ruby-devel libvirt-client bind bind-utils dhcp tftp syslinux* tftp-server
sleep 5
echo ""
echo "*********************************************************"
echo "INSTALLING DEPENDENCIES FOR CONTENT VIEW AUTO PUBLISH"
echo "*********************************************************"
yum -y install python-pip rubygem-builder
yum-config manager --disable epel
pip install --upgrade pip
yum clean all ; rm -rf /var/cache/yum
yum upgrade -y; yum update -y
}
#----------------------------------
function GENERALSETUP {
#----------------------------------
echo ""
echo "*********************************************************"
echo 'GENERAL SETUP'
echo "*********************************************************"
echo -ne "\e[8;40;170t"
source /root/.bashrc
echo " "
echo "*********************************************************"
echo "GENERATE USERS AND SYSTEM KEYS FOR REQUIRED USERS"
echo "*********************************************************"
echo ""
echo "*********************************************************"
echo "SETTING UP ADMIN"
echo "*********************************************************"
groupadd admin
useradd admin -g admin -m -p $ADMIN
mkdir -p /home/admin/.ssh
mkdir -p /home/admin/git
chown -R admin:admin /home/admin
sudo -u admin ssh-keygen -f /home/admin/.ssh/id_rsa -N ''
echo " "
echo "*********************************************************"
echo "SETTING UP FOREMAN-PROXY"
echo "*********************************************************"
useradd -M foreman-proxy
usermod -L foreman-proxy
mkdir -p /usr/share/foreman-proxy/.ssh
sudo -u foreman-proxy ssh-keygen -f /usr/share/foreman-proxy/.ssh/id_rsa_foreman_proxy -N ''
chown -R foreman-proxy:foreman-proxy /usr/share/foreman-proxy
echo " "
echo "*********************************************************"
echo "ROOT"
echo "*********************************************************"
ssh-keygen -f /root/.ssh/id_rsa -t rsa -N ''
echo " "
echo "*********************************************************"
echo 'SET DOMAIN' 
echo "*********************************************************"
cp /etc/sysctl.conf /etc/sysctl.conf.bak
echo 'inet.ipv4.ip_forward=1' >> /etc/sysctl.conf
echo "kernel.domainname=$DOM" >> /etc/sysctl.conf
echo " "
echo "*********************************************************"
echo "GENERATE /ETC/HOSTS"
echo "*********************************************************"
cp /etc/hosts /etc/hosts.bak
echo "${SAT_IP} $(hostname)" >>/etc/hosts
echo " "
echo "*********************************************************"
echo "ADDING KATELLO-CVMANAGER TO /HOME/ADMIN/GIT "
echo "*********************************************************"
mkdir cd /home/admin/Downloads/git
cd /home/admin/Downloads/git
git clone https://github.com/RedHatSatellite/katello-cvmanager.git
git clone https://github.com/flyemsafe/my-satellite-post-config.git
gem install apipie-bindings || true
cd 
mkdir -p /root/.hammer
echo " "
echo "*********************************************************"
echo "SETTING ADMIN USER TO NO PASSWORD FOR SUDO"
echo "*********************************************************"
cp /etc/sudoers /etc/sudoers.bak
echo 'admin ALL = NOPASSWD: ALL' >> /etc/sudoers
echo " "
}
#  --------------------------------------
function SYSCHECK {
#  --------------------------------------
echo " "
echo "*********************************************************"
echo "CHECKING ALL REQUIREMENTS HAVE BEEN MET"
echo "*********************************************************"
echo " "
echo "*********************************************************"
echo "CHECKING FQDN"
echo "*********************************************************"
hostname -f 
if [ $? -eq 0 ]; then
    echo 'The FQDN is as expected $(hostname)'
else
    echo "The FQDN is not defined please correct and try again"
    mv /root/.bashrc.bak /root/.bashrc
    mv /etc/sudoers.bak /etc/sudoers
    mv /etc/hosts.bak /etc/hosts
    mv /etc/sysctl.conf.bak /etc/sysctl.conf
    rm -f ./SCRIPT
    subscription-manager unregister
    subscription manager clean
    sleep 10
    exit
sleep 5
echo " "
fi
echo "*********************************************************"
echo "CHECKING FOR ADMIN USER"
echo "*********************************************************"
getent passwd admin > /dev/null 2&>1
if [ $? -eq 0 ]; then
    echo "yes the admin user exists"
else
    echo "No, the user does not exist
    The user does not exist please create a admin user
    and try again."
    sleep 10
    exit
sleep 5
echo " "
fi
}
#  --------------------------------------
function INSTALLNSAT {
#  --------------------------------------
echo " "
echo "*********************************************************"
echo "INSTALLING SATELLITE"
echo "*********************************************************"
echo " "
echo -ne "\e[8;40;170t"
source /root/.bashrc
echo "Disabling EPEL repos"
yum-config-manager --disable epel
echo " "
echo "Enabling Repos -> RHEL 7, RHSCL 7, Optional, Satellite 6.4, and Satellite Maintenance 6.0"
subscription-manager repos --enable=rhel-7-server-rpms || exit 1
subscription-manager repos --enable=rhel-server-rhscl-7-rpms || exit 1
subscription-manager repos --enable=rhel-7-server-optional-rpms || exit 1
subscription-manager repos --enable=rhel-7-server-satellite-6.4-rpms || exit 1
subscription-manager repos --enable=rhel-7-server-satellite-maintenance-6-rpms || exit 1
yum clean all 
rm -rf /var/cache/yum
echo " "
echo "*********************************************************"
echo "INSTALLING RPMS"
echo "*********************************************************"
echo "Installing Satellite 6.4"
yum -q list installed satellite &>/dev/null && echo "satellite is installed" || time yum install satellite -y --skip-broken
echo "Installing puppetserver"
yum -q list installed puppetserver &>/dev/null && echo "puppetserver is installed" || time yum install puppetserver -y --skip-broken
echo "Installing puppet-agent-oauth"
yum -q list installed puppet-agent-oauth &>/dev/null && echo "puppet-agent-oauth is installed" || time yum install puppet-agent-oauth -y --skip-broken
echo "Installing puppet-agent"
yum -q list installed puppet-agent &>/dev/null && echo "puppet-agent is installed" || time yum install puppet-agent -y --skip-broken
echo "foreman-proxy"
yum -q list installed foreman-proxy &>/dev/null && echo "foreman-proxy is installed" || time yum install foreman-proxy -y --skip-broken
subscription-manager repos --enable=rhel-7-server-extras-rpms
yum -q list installed rhel-system-roles &>/dev/null && echo "rhel-system-roles are installed" || time yum install rhel-system-roles -y --skip-broken
subscription-manager repos --disable=rhel-7-server-extras-rpms
}
#---END OF SAT 6.X INSTALL SCRIPT---

#---START OF SAT 6.X CONFIGURE SCRIPT---
#  --------------------------------------
function CONFSAT {
#  --------------------------------------
echo " "
source /root/.bashrc
echo -ne "\e[8;40;170t"
echo "*********************************************************"
echo "CONFIGURING SATELLITE"
echo "*********************************************************"
echo " "
echo "*********************************************************"
echo "CONFIGURING SATELLITE BASE"
echo "*********************************************************"
satellite-installer --scenario satellite -v \
--foreman-admin-password=$ADMIN_PASSWORD \
--foreman-admin-username=$ADMIN \
--foreman-initial-organization=$ORG \
--foreman-initial-location=$LOC \
--foreman-proxy-dns true \
--foreman-proxy-dns-managed=true \
--foreman-proxy-dns-provider=nsupdate \
--foreman-proxy-dns-server="127.0.0.1" \
--foreman-proxy-dns-interface $SAT_INTERFACE \
--foreman-proxy-dns-zone=$DOM \
--foreman-proxy-dns-forwarders $DNS \
--foreman-proxy-dns-tsig-principal="foreman-proxy $(hostname)@$DOM" \
--foreman-proxy-dns-tsig-keytab=/etc/foreman-proxy/dns.key \
--foreman-proxy-dns-listen-on both \
--foreman-proxy-dns-reverse $DNS_REV
echo " "
echo "*********************************************************"
echo "CONFIGURING SATELLITE DHCP"
echo "*********************************************************"
source /root/.bashrc
satellite-installer --scenario satellite -v \
--foreman-proxy-dhcp-managed=true \
--foreman-proxy-dhcp=true \
--foreman-proxy-dhcp-server=$INTERNALIP \
--foreman-proxy-dhcp-interface=$SAT_INTERFACE \
--foreman-proxy-dhcp-range="$DHCP_RANGE" \
--foreman-proxy-dhcp-gateway=$DHCP_GW \
--foreman-proxy-dhcp-nameservers=$DHCP_DNS \
--foreman-proxy-dhcp-listen-on both \
--foreman-proxy-dhcp-search-domains=$DOM

echo " "
echo "*********************************************************"
echo "CONFIGURING SATELLITE TFTP"
echo "*********************************************************"
source /root/.bashrc
satellite-installer --scenario satellite -v \
--foreman-proxy-tftp=true \
--foreman-proxy-tftp-listen-on both \
--foreman-proxy-tftp-servername=$SAT_IP
echo " "
echo "*********************************************************"
echo "CONFIGURING ALL SATELLITE PLUGINS"
echo "*********************************************************"
yum groupinstall -y 'Red Hat Satellite'
yum -q list installed puppet-foreman_scap_client &>/dev/null && echo "puppet-foreman_scap_client is installed" || yum install -y puppet-foreman_scap_client* --skip-broken
yum -q list installed foreman-discovery-image &>/dev/null && echo "foreman-discovery-image is installed" || yum install -y foreman-discovery-image* --skip-broken
yum -q list installed rubygem-smart_proxy_discovery &>/dev/null && echo "rubygem-smart_proxy_discovery is installed" || yum install -y rubygem-smart_proxy_discovery* --skip-broken 

source /root/.bashrc
satellite-installer --scenario satellite -v \
--foreman-proxy-plugin-discovery-install-images true \
--enable-foreman-plugin-discovery \
--foreman-plugin-tasks-automatic-cleanup true \
--foreman-proxy-content-enable-ostree true \
--enable-foreman-plugin-docker \
--enable-foreman-plugin-ansible \
--enable-foreman-plugin-hooks \
--enable-foreman-plugin-openscap \
--enable-foreman-plugin-templates \
--enable-foreman-plugin-tasks \
--enable-foreman-compute-ec2 \
--enable-foreman-compute-gce \
--enable-foreman-compute-libvirt \
--enable-foreman-compute-openstack \
--enable-foreman-compute-ovirt \
--enable-foreman-compute-rackspace \
--enable-foreman-compute-vmware \
--enable-foreman-plugin-bootdisk \
--foreman-proxy-http true \
--foreman-proxy-ssl=true \
--foreman-proxy-templates-listen-on both \
--foreman-proxy-puppet-listen-on both \
--foreman-proxy-templates=true

echo " "
echo "*********************************************************"
echo "ENABLE DEB"
echo "*********************************************************"
foreman-installer -v --foreman-proxy-content-enable-deb=true --katello-enable-deb
echo " "
echo "*********************************************************"
echo "CONFIGURING SATELLITE CACHE"
echo "*********************************************************"
foreman-rake apipie:cache:index --trace
echo " "
echo "*********************************************************"
echo "DHCP SATELLITE"
echo "*********************************************************"
echo " "
DEFAULTDHCP=y
read -n1 -p "Would like to use the DHCP server provided by Satellite? y/n " INPUT
INPUT=${INPUT:-$DEFAULTDHCP}
if  [ "$INPUT" = "y" -o "$INPUT" = "Y" ] ;then
echo " "
echo "DHCPD ENABLED"
#COMMANDEXECUTION
elif [ "$INPUT" = "n" -o "$INPUT" = "N" ] ;then
echo " "
echo "DHCPD DISABLED"
chkconfig dhcpd off
service dhcpd stop
#COMMANDEXECUTION
else
echo -e "\n$FMESSAGE\n"
REQUEST
fi
}
#------------------------------
function HAMMERCONF {
#------------------------------
echo "*********************************************************"
echo "CONFIGURING HAMMER"
echo "*********************************************************"
echo -ne "\e[8;40;170t"
source /root/.bashrc
echo "*********************************************************"
echo "Enabling Hammer for Satellite configuration tasks"
echo "Setting up hammer will list the Satellite username and password in the /root/.hammer/cli_config.yml file
with default permissions set to -rw-r--r--, if this is a security concern it is recommended the file is
deleted once the setup is complete"
echo "*********************************************************"
read -p "Press [Enter] to continue"
sleep 10
cat > /root/.hammer/cli_config.yml<< EOF
:foreman:
 :host: 'https://$(hostname -f)'
 :username: '$ADMIN'
 :password: '$ADMIN_PASSWORD'
:log_dir: '/var/log/foreman'
:log_level: 'error'
EOF
sed -i 's/example/redhat/g' /etc/hammer/cli.modules.d/foreman.yml
sed -i 's/#:password/:password/g' /etc/hammer/cli.modules.d/foreman.yml
}
#  --------------------------------------
function CONFIG2 {
#  --------------------------------------
source /root/.bashrc
echo -ne "\e[8;40;170t"
echo ' '
echo "*********************************************************"
echo 'Download manifest from https://access.redhat.com/management/subscription_allocations/
 so you can build and export the manifest (just in case).
This must be saved into the /home/admin/Downloads directory'
echo "*********************************************************"
echo ' '
read -p "Press [Enter] to continue"
echo ' '
echo ' '
echo "*********************************************************"
echo 'If you have put your manafest into /home/admin/Downloads/'
echo "*********************************************************"
read -p "Press [Enter] to continue"
sleep 5
echo "*********************************************************"
echo 'WHEN PROMPTED PLEASE ENTER YOUR SATELLITE ADMIN USERNAME AND PASSWORD'
echo "*********************************************************"
sleep 5
chown -R admin:admin /home/admin
source /root/.bashrc
for i in $(find /home/admin/Downloads/ |grep manifest* ); do sudo -u admin hammer subscription upload --file $i --organization $ORG ; done  || exit 1
hammer subscription refresh-manifest --organization $ORG
hammer subscription list --organization "$ORG" | ( grep -q 'Red Hat' && echo all ok, proceeding ) || ( echo "Subscription import has not been successful. Exit"; exit 1 )
echo "*********************************************************"
echo 'REFRESHING THE CAPSULE CONTENT'
echo "*********************************************************"
for i in $(hammer capsule list |awk -F '|' '{print $1}' |grep -v ID|grep -v -) ; do hammer capsule refresh-features --id=$i ; done 
sleep 5
echo "*********************************************************"
echo 'SETTING SATELLITE EVN SETTINGS'
echo "*********************************************************"
hammer settings set --name default_download_policy --value on_demand
hammer settings set --name default_organization  --value $ORG
hammer settings set --name default_location  --value $LOC
hammer settings set --name discovery_organization  --value $ORG
hammer settings set --name root_pass --value $NODEPASS
hammer settings set --name register_hostname_fact  --value network.hostname-override

mkdir -p /etc/puppet/environments/production/modules
}
#-------------------------------
function STOPSPAMMINGVARLOG {
#-------------------------------
source /root/.bashrc
echo -ne "\e[8;40;170t"
echo "*********************************************************"
echo "STOP THE LOG SPAMMING OF /VAR/LOG/MESSAGES WITH SLICE"
echo "*********************************************************"
echo 'if $programname == "systemd" and ($msg contains "Starting Session" or $msg contains "Started Session" or $msg contains "Created slice" or $msg contains "Starting user-" or $msg contains "Starting User Slice of" or $msg contains "Removed session" or $msg contains "Removed slice User Slice of" or $msg contains "Stopping User Slice of") then stop' > /etc/rsyslog.d/ignore-systemd-session-slice.conf
systemctl restart rsyslog 
}
source /root/.bashrc

QMESSAGE6="Would you like to enable and sync RHEL 6 Content
This will enable
 Red Hat Enterprise Linux 6 Server (Kickstart)
 Red Hat Enterprise Linux 6 Server
 Red Hat Satellite Tools 6.4 (for RHEL 6 Server)
 Red Hat Software Collections RPMs for Red Hat Enterprise Linux 6 Server
 Red Hat Enterprise Linux 6 Server - Extras
 Red Hat Enterprise Linux 6 Server - Optional
 Red Hat Enterprise Linux 6 Server - Supplementary
 Red Hat Enterprise Linux 6 Server - RH Common
 Extra Packages for Enterprise Linux 6"

QMESSAGEICENTOS7="Would you like to download CentOS-7 custom content"

YMESSAGE="Adding avalable content."
NMESSAGE="Skipping avalable content"
FMESSAGE="PLEASE ENTER Y or N"
COUNTDOWN=15
CENTOS7DEFAULTVALUE=y

#-------------------------------
function REQUESTSYNCMGT {
#-------------------------------
echo "*********************************************************"
echo "Configuring Repositories"
echo "*********************************************************"
echo "*********************************************************"
echo "BY DEFAULT IF YOU JUST LET THIS SCRIPT RUN YOU WILL 
ONLY SYNC THE  CORE RHEL 7 (KICKSTART, 7SERVER, OPTIONAL, EXTRAS,
 SAT 6.4 TOOLS, SUPPLAMENTRY, AND RH COMMON ) THE PROGRESS 
 TO THIS STEP CAN BE TRACKED AT $(hostname)/katello/sync_management :"
echo "*********************************************************"
if ! xset q &>/dev/null; then
    echo "No X server at \$DISPLAY [$DISPLAY]" >&2
    echo 'In a system browser please goto the URL to view progress https://$(hostname)/katello/sync_management'
    sleep 10
else 
    firefox https://$(hostname)/katello/sync_management &
fi
}
#-------------------------------
function REQUESTPUPPET {
#-------------------------------
source /root/.bashrc
echo -ne "\e[8;40;170t"
echo "*********************************************************"
echo "PUPPET FORGE:"
echo "*********************************************************"
hammer product create --name='Puppet Forge' --organization $ORG
hammer repository create --name='Puppet Forge' --organization $ORG --product='Puppet Forge' --content-type puppet --publish-via-http=true --url=https://forge.puppetlabs.com
du -sh /var/lib/pulp/content/units/puppet_module
find /var/lib/pulp/content/units/puppet_module -name \*tar.gz|wc -l
sleep 5
}
#-------------------------------
function REQUEST6 {
#-------------------------------
source /root/.bashrc
echo -ne "\e[8;40;170t"
echo "*********************************************************"
echo "RHEL 6 STANDARD REPOS:"
echo "*********************************************************"
read -n1 -t $COUNTDOWN -p "$QMESSAGE6 ? Y/N " INPUT
INPUT=${INPUT:-$RHEL6DEFAULTVALUE}
if  [ "$INPUT" = "y" -o "$INPUT" = "Y" ] ;then
echo -e "\n$YMESSAGE\n"
sleep 2
echo "*********************************************************"
echo "Red Hat Enterprise Linux 6 Server (Kickstart):"
echo "*********************************************************"
hammer repository-set enable --organization $ORG --product 'Red Hat Enterprise Linux Server' --basearch='x86_64' --releasever='6Server' --name 'Red Hat Enterprise Linux 6 Server (Kickstart)'
hammer repository update --organization $ORG --product 'Red Hat Enterprise Linux Server' --basearch='x86_64' --releasever='6.10' --name 'Red Hat Enterprise Linux 6 Server (Kickstart)' --download-policy immediate
sleep 2
echo "*********************************************************"
echo "Red Hat Enterprise Linux 6 Server (RPMs):"
echo "*********************************************************"
hammer repository-set enable --organization $ORG --product 'Red Hat Enterprise Linux Server' --basearch='x86_64' --releasever='6Server' --name 'Red Hat Enterprise Linux 6 Server (RPMs)'
sleep 2
echo "*********************************************************"
echo "Red Hat Satellite Tools 6.4 (for RHEL 6 Server) (RPMs):"
echo "*********************************************************"
hammer repository-set enable --organization $ORG --product 'Red Hat Enterprise Linux Server' --basearch='x86_64' --name 'Red Hat Satellite Tools 6.4 (for RHEL 6 Server) (RPMs)'
sleep 2
echo "*********************************************************"
echo "Red Hat Enterprise Linux 6 Server - Optional (RPMs):"
echo "*********************************************************"
hammer repository-set enable --organization $ORG --product 'Red Hat Enterprise Linux Server' --basearch='x86_64' --releasever='6Server' --name 'Red Hat Enterprise Linux 6 Server - Optional (RPMs)'
sleep 2
echo "*********************************************************"
echo "Red Hat Enterprise Linux 6 Server - Extras (RPMs):"
echo "*********************************************************"
hammer repository-set enable --organization $ORG --product 'Red Hat Enterprise Linux Server' --basearch='x86_64' --name 'Red Hat Enterprise Linux 6 Server - Extras (RPMs)'
sleep 2
echo "*********************************************************"
echo "Red Hat Enterprise Linux 6 Server - RH Common (RPMs):"
echo "*********************************************************"
hammer repository-set enable --organization $ORG --product 'Red Hat Enterprise Linux Server' --basearch='x86_64' --releasever='6Server' --name 'Red Hat Enterprise Linux 6 Server - RH Common (RPMs)'
sleep 2
echo "*********************************************************"
echo "Red Hat Enterprise Linux 6 Server - Supplementary (RPMs):"
echo "*********************************************************"
hammer repository-set enable --organization $ORG --product 'Red Hat Enterprise Linux Server' --basearch='x86_64' --releasever='6Server' --name 'Red Hat Enterprise Linux 6 Server - Supplementary (RPMs)'
sleep 2
echo "*********************************************************"
echo "RHN Tools for Red Hat Enterprise Linux 6 Server (RPMs):"
echo "*********************************************************"
hammer repository-set enable --organization $ORG --product 'Red Hat Enterprise Linux Server' --basearch='x86_64' --releasever='6Server' --name 'RHN Tools for Red Hat Enterprise Linux 6 Server (RPMs)'
sleep 2
echo "*********************************************************"
echo "Red Hat Satellite Tools 6.4 (for RHEL 6 Server) (RPMs):"
echo "*********************************************************"
hammer repository-set enable --organization "$ORG" --product 'Red Hat Enterprise Linux Server' --basearch='x86_64' --name 'Red Hat Satellite Tools 6.4 (for RHEL 6 Server) (RPMs)'
sleep 2
echo "*********************************************************"
echo "Red Hat Enterprise Linux 6 Server (ISOs):"
echo "*********************************************************"
hammer repository-set enable --organization $ORG --product 'Red Hat Enterprise Linux Server' --basearch='x86_64' --releasever='6Server' --name 'Red Hat Enterprise Linux 6 Server (ISOs)'
sleep 2
echo "*********************************************************"
echo "Extra Packages for Enterprise Linux 6:"
echo "*********************************************************"
wget -q https://dl.fedoraproject.org/pub/epel/RPM-GPG-KEY-EPEL-6 -O /root/RPM-GPG-KEY-EPEL-6
hammer gpg create --key /root/RPM-GPG-KEY-EPEL-6 --name 'GPG-EPEL-6' --organization $ORG
hammer product create --name='Extra Packages for Enterprise Linux 6' --organization $ORG
hammer repository create --name='Extra Packages for Enterprise Linux 6' --organization $ORG --product='Extra Packages for Enterprise Linux 6' --content-type=yum --publish-via-http=true --url=http://dl.fedoraproject.org/pub/epel/6/x86_64/ --checksum-type=sha256 --gpg-key=GPG-EPEL-6
sleep 2
#COMMANDEXECUTION
elif [ "$INPUT" = "n" -o "$INPUT" = "N" ] ;then
echo -e "\n$NMESSAGE\n"
#COMMANDEXECUTION
else
echo -e "\n$FMESSAGE\n"
fi
}
#-------------------------------
function REQUEST7 {
#-------------------------------
source /root/.bashrc
echo -ne "\e[8;40;170t"
echo "*********************************************************"
echo "RHEL 7 STANDARD REPOS:"
echo "*********************************************************"
echo "*********************************************************"
echo "Red Hat Enterprise Linux 7 Server (Kickstart):"
echo "*********************************************************"
hammer repository-set enable --organization "$ORG" --product 'Red Hat Enterprise Linux Server' --basearch='x86_64' --releasever='7.6' --name 'Red Hat Enterprise Linux 7 Server (Kickstart)' 
hammer repository update --organization "$ORG" --product 'Red Hat Enterprise Linux Server' --name 'Red Hat Enterprise Linux 7 Server Kickstart x86_64 7.6' --download-policy immediate
sleep 2
echo "*********************************************************"
echo "Red Hat Enterprise Linux 7 Server (RPMs):"
echo "*********************************************************"
hammer repository-set enable --organization "$ORG" --product 'Red Hat Enterprise Linux Server' --basearch='x86_64' --releasever='7Server' --name 'Red Hat Enterprise Linux 7 Server (RPMs)'
sleep 2
echo "*********************************************************"
echo "Red Hat Enterprise Linux 7 Server - Supplementary (RPMs):"
echo "*********************************************************"
hammer repository-set enable --organization "$ORG" --product 'Red Hat Enterprise Linux Server' --basearch='x86_64' --releasever='7Server' --name 'Red Hat Enterprise Linux 7 Server - Supplementary (RPMs)'
sleep 2
echo "*********************************************************"
echo "Red Hat Enterprise Linux 7 Server - Optional (RPMs):"
echo "*********************************************************"
hammer repository-set enable --organization "$ORG" --product 'Red Hat Enterprise Linux Server' --basearch='x86_64' --releasever='7Server' --name 'Red Hat Enterprise Linux 7 Server - Optional (RPMs)'
sleep 2
echo "*********************************************************"
echo "Red Hat Enterprise Linux 7 Server - Extras (RPMs):"
echo "*********************************************************"
hammer repository-set enable --organization "$ORG" --product 'Red Hat Enterprise Linux Server' --basearch='x86_64' --name 'Red Hat Enterprise Linux 7 Server - Extras (RPMs)'
sleep 2
echo "*********************************************************"
echo "Red Hat Satellite Tools 6.4 (for RHEL 7 Server) (RPMs):"
echo "*********************************************************"
hammer repository-set enable --organization "$ORG" --product 'Red Hat Enterprise Linux Server' --basearch='x86_64' --name 'Red Hat Satellite Tools 6.4 (for RHEL 7 Server) (RPMs)'
sleep 2
echo "*********************************************************"
echo "Red Hat Enterprise Linux 7 Server - RH Common (RPMs):"
echo "*********************************************************"
hammer repository-set enable --organization "$ORG" --product 'Red Hat Enterprise Linux Server' --basearch='x86_64' --releasever='7Server' --name 'Red Hat Enterprise Linux 7 Server - RH Common (RPMs)'
sleep 2
echo "*********************************************************"
echo "'Red Hat Software Collections RPMs for Red Hat Enterprise Linux 7 Server:"
echo "*********************************************************"
hammer repository-set enable --organization "$ORG" --product 'Red Hat Software Collections (for RHEL Server)' --basearch='x86_64' --releasever='7Server' --name 'Red Hat Software Collections RPMs for Red Hat Enterprise Linux 7 Server'
sleep 2
echo "*********************************************************"
echo "'Extra Packages for Enterprise Linux 7:"
echo "*********************************************************"
wget -q https://dl.fedoraproject.org/pub/epel/RPM-GPG-KEY-EPEL-7 -O /root/RPM-GPG-KEY-EPEL-7
sleep 2
wget -q https://dl.fedoraproject.org/pub/epel/RPM-GPG-KEY-EPEL-7Server -O /root/RPM-GPG-KEY-EPEL-7Server
sleep 2
hammer gpg create --key /root/RPM-GPG-KEY-EPEL-7  --name 'GPG-EPEL-7' --organization $ORG
hammer gpg create --key /root/RPM-GPG-KEY-EPEL-7Server  --name 'GPG-EPEL-7Sever' --organization $ORG
sleep 2
hammer product create --name='Extra Packages for Enterprise Linux 7' --organization $ORG
hammer product create --name='Extra Packages for Enterprise Linux 7Server' --organization $ORG
sleep 2
hammer repository create --name='Extra Packages for Enterprise Linux 7' --organization $ORG --product='Extra Packages for Enterprise Linux 7' --content-type yum --publish-via-http=true --url=https://dl.fedoraproject.org/pub/epel/7/x86_64/
sleep 2
hammer repository create --name='Extra Packages for Enterprise Linux 7Server' --organization $ORG --product='Extra Packages for Enterprise Linux 7Server' --content-type yum --publish-via-http=true --url=https://dl.fedoraproject.org/pub/epel/7Server/x86_64/
sleep 2
}
#-------------------------------
function REQUESTCENTOS7 {
#-------------------------------
source /root/.bashrc
echo -ne "\e[8;40;170t"
echo "*********************************************************"
echo "CentOS-7:"
echo "*********************************************************"
read -n1 -t$COUNTDOWN -p "$QMESSAGEICENTOS7 ? Y/N " INPUT
INPUT=${INPUT:-$CENTOS7DEFAULTVALUE}
if  [ "$INPUT" = "y" -o "$INPUT" = "Y" ] ;then
echo -e "\n$YMESSAGE\n"
cd /root/Downloads
wget http://mirror.centos.org/centos/RPM-GPG-KEY-CentOS-7
hammer gpg create --organization $ORG --name RPM-GPG-KEY-CentOS-7 --key RPM-GPG-KEY-CentOS-7
hammer product create --name='CentOS-7' --organization $ORG
hammer repository create  --organization $ORG --name='CentOS-7 (Kickstart)' --product='CentOS-7' --content-type='yum' --gpg-key='RPM-GPG-KEY-CentOS-7' --publish-via-http=true --url=http://mirror.centos.org/centos/7.6.1810/os/x86_64/ --download-policy immediate --checksum-type=sha256
sleep 2
hammer repository create  --organization $ORG --name='CentOS-7 CentOSplus' --product='CentOS-7' --content-type='yum' --gpg-key='RPM-GPG-KEY-CentOS-7' --publish-via-http=true --url=http://mirror.centos.org/centos/7.6.1810/centosplus/x86_64/ --checksum-type=sha256
sleep 2
hammer repository create  --organization $ORG --name='CentOS-7 DotNET' --product='CentOS-7' --content-type='yum' --gpg-key='RPM-GPG-KEY-CentOS-7' --publish-via-http=true --url=http://mirror.centos.org/centos/7.6.1810/dotnet/x86_64/ --checksum-type=sha256
sleep 2
hammer repository create  --organization $ORG --name='CentOS-7 Extras' --product='CentOS-7' --content-type='yum' --gpg-key='RPM-GPG-KEY-CentOS-7' --publish-via-http=true --url=http://mirror.centos.org/centos/7.6.1810/extras/x86_64/ --checksum-type=sha256
sleep 2
hammer repository create  --organization $ORG --name='CentOS-7 Fasttrack' --product='CentOS-7' --content-type='yum' --gpg-key='RPM-GPG-KEY-CentOS-7' --publish-via-http=true --url=http://mirror.centos.org/centos/7.6.1810/fasttrack/x86_64/ --checksum-type=sha256
sleep 2
hammer repository create  --organization $ORG --name='CentOS-7 ISO' --product='CentOS-7' --content-type='yum' --gpg-key='RPM-GPG-KEY-CentOS-7' --publish-via-http=true --url=http://centos.host-engine.com/7.6.1810/isos/x86_64/CentOS-7-x86_64-DVD-1810.iso --checksum-type=sha256
sleep 2
hammer repository create  --organization $ORG --name='CentOS-7 Openshift-Origin' --product='CentOS-7' --content-type='yum' --gpg-key='RPM-GPG-KEY-CentOS-7' --publish-via-http=true --url=http://mirror.centos.org/centos/7.6.1810/paas/x86_64/openshift-origin/ --checksum-type=sha256
sleep 2
hammer repository create  --organization $ORG --name='CentOS-7 OpsTools' --product='CentOS-7' --content-type='yum' --gpg-key='RPM-GPG-KEY-CentOS-7' --publish-via-http=true --url=http://mirror.centos.org/centos/7.6.1810/opstools/x86_64/ --checksum-type=sha256
sleep 2
hammer repository create  --organization $ORG --name='CentOS-7 Gluster 5' --product='CentOS-7' --content-type='yum' --gpg-key='RPM-GPG-KEY-CentOS-7' --publish-via-http=true --url=http://mirror.centos.org/centos/7.6.1810/storage/x86_64/gluster-5/ --checksum-type=sha256
sleep 2
hammer repository create  --organization $ORG --name='CentOS-7 Ceph-Luminous' --product='CentOS-7' --content-type='yum' --gpg-key='RPM-GPG-KEY-CentOS-7' --publish-via-http=true --url=http://mirror.centos.org/centos/7.6.1810/storage/x86_64/ceph-luminous/ --checksum-type=sha256
sleep 2
hammer repository create  --organization $ORG --name='CentOS-7 Updates' --product='CentOS-7' --content-type='yum' --gpg-key='RPM-GPG-KEY-CentOS-7' --publish-via-http=true --url=http://mirror.centos.org/centos/7.6.1810/updates/x86_64/ --checksum-type=sha256
sleep 2
echo 'CENTOS7DEFAULTVALUE=y' >> /root/.bashrc
#COMMANDEXECUTION
elif [ "$INPUT" = "n" -o "$INPUT" = "N" ] ;then
echo -e "\n$NMESSAGE\n"
#COMMANDEXECUTION
else
echo -e "\n$FMESSAGE\n"
fi
}
#-------------------------------
function SYNC {
#------------------------------
source /root/.bashrc
echo -ne "\e[8;40;170t"
echo " "
echo "*********************************************************"
echo "SYNC ALL REPOSITORIES (WAIT FOR THIS TO COMPLETE BEFORE CONTINUING):"
echo "*********************************************************"
for i in $(hammer --csv repository list --organization $ORG | awk -F, {'print $1'} | grep -vi '^ID'); do time hammer repository synchronize --id ${i} --organization $ORG --async ; done
sleep 2000
echo " "
}
#-------------------------------
function SYNCMSG {
#------------------------------
echo " "
if ! xset q &>/dev/null; then
echo "No X server at \$DISPLAY [$DISPLAY]" >&2
echo 'In a system browser please goto the URL to view progress https://$(hostname)/katello/sync_management'
sleep 2
else 
    firefox https://$(hostname)/katello/sync_management &
fi
echo " "
}
#-------------------------------
function PRIDOMAIN {
#------------------------------
source /root/.bashrc
echo -ne "\e[8;40;170t"
echo "*********************************************************"
echo 'UPDATING DOMAIN'
echo "*********************************************************"
hammer domain update --id 1 --organizations $ORG --locations $LOC
}
#-------------------------------
function CREATESUBNET {
#------------------------------
source /root/.bashrc
echo -ne "\e[8;40;170t"
echo "*********************************************************"
echo "CREATE THE FIRST OR PRIMARY SUBNET TO CONNECT THE NODES TO THE SATELLITE:"
echo "*********************************************************"
echo " "
hammer subnet create --name $SUBNET_NAME --network $INTERNALNETWORK --mask $SUBNET_MASK --gateway $DHCP_GW --dns-primary $DNS --ipam 'Internal DB' --from $SUBNET_IPAM_BEGIN --to $SUBNET_IPAM_END --tftp-id 1 --dhcp-id 1 --dns-id 1 --domain-ids 1 --organizations $ORG --locations "$LOC"
}
#-------------------------------
function ENVIRONMENTRHEL7 {
#-------------------------------
source /root/.bashrc
echo -ne "\e[8;40;170t"
echo " "
echo "*********************************************************"
echo "CREATE ENVIRONMENTS DEV_RHEL_7->TEST_RHEL_7->PROD_RHEL_7:"
echo "*********************************************************"
echo 'UNSTAGED_RHEL_7'
hammer lifecycle-environment create --name='UNSTAGED_RHEL_7' --prior='Library' --organization $ORG
echo "DEVLOPMENT_RHEL_7"
hammer lifecycle-environment create --name='DEV_RHEL_7' --prior='UNSTAGED_RHEL_7' --organization $ORG
echo "TEST_RHEL_7"
hammer lifecycle-environment create --name='TEST_RHEL_7' --prior='DEV_RHEL_7' --organization $ORG
echo "PRODUCTION_RHEL_7"
hammer lifecycle-environment create --name='PROD_RHEL_7' --prior='TEST_RHEL_7' --organization $ORG
}
#-------------------------------
function ENVIRONMENTRHEL6 {
#-------------------------------
source /root/.bashrc
echo -ne "\e[8;40;170t"
echo " "
INPUT=${INPUT:-$RHEL6DEFAULTVALUE}
if  [ "$INPUT" = "y" -o "$INPUT" = "Y" ] ;then
echo "*********************************************************"
echo "CREATE ENVIRONMENTS DEV_RHEL_6->TEST_RHEL_6->PROD_RHEL_6:"
echo "*********************************************************"
echo 'UNSTAGED_RHEL_6'
hammer lifecycle-environment create --name='UNSTAGED_RHEL_6' --prior='Library' --organization $ORG
echo "DEVLOPMENT_RHEL_6"
hammer lifecycle-environment create --name='DEV_RHEL_6' --prior='UNSTAGED_RHEL_6' --organization $ORG
echo "TEST_RHEL_6"
hammer lifecycle-environment create --name='TEST_RHEL_6' --prior='DEV_RHEL_6' --organization $ORG
echo "PRODUCTION_RHEL_6"
hammer lifecycle-environment create --name='PROD_RHEL_6' --prior='TEST_RHEL_6' --organization $ORG
fi
}
#-------------------------------
function ENVIRONMENTCENTOS7 {
#-------------------------------
source /root/.bashrc
echo -ne "\e[8;40;170t"
echo " "
INPUT=${INPUT:-$CENTOS7DEFAULTVALUE}
if  [ "$INPUT" = "y" -o "$INPUT" = "Y" ] ;then
echo "*********************************************************"
echo "CREATE ENVIRONMENTS DEV_CENTOS_7->TEST_CENTOS_7->PROD_CENTOS_7:"
echo "*********************************************************"
echo 'UNSTAGED_CentOS_7'
hammer lifecycle-environment create --name='UNSTAGED_CentOS_7' --prior='Library' --organization $ORG
echo "DEVLOPMENT_CentOS_7"
hammer lifecycle-environment create --name='DEV_CentOS_7' --prior='UNSTAGED_CentOS_7' --organization $ORG
echo "TEST_CentOS_7"
hammer lifecycle-environment create --name='TEST_CentOS_7' --prior='DEV_CentOS_7' --organization $ORG
echo "PRODUCTION_CentOS_7"
hammer lifecycle-environment create --name='PROD_CentOS_7' --prior='TEST_CentOS_7' --organization $ORG
echo " "
fi
}
#-------------------------------
function SYNCPLANS {
#-------------------------------
source /root/.bashrc
echo -ne "\e[8;40;170t"
echo " "
echo "*********************************************************"
echo "Create sync plans:"
echo "*********************************************************"
hammer sync-plan create --name 'Daily_Sync' --description 'Daily Synchronization Plan' --organization $ORG --interval daily --sync-date $(date +"%Y-%m-%d")" 00:00:00" --enabled no
hammer sync-plan create --name 'Weekly_Sync' --description 'Weekly Synchronization Plan' --organization $ORG --interval weekly --sync-date $(date +"%Y-%m-%d")" 00:00:00" --enabled yes
for i in $(hammer --csv product list --organization $ORG --per-page 999 | grep -vi '^ID' | grep -vi not_synced | awk -F, {'{ if ($5!=0) print $1}'})
do
hammer product set-sync-plan --sync-plan "Weekly_Sync" --organization $ORG --id $i
done
echo " "
}

#--------------------------End Primary Functions--------------------------

#-----------------------
function dMainMenu {
#-----------------------
$DIALOG --stdout --title "Red Hat Sat 6.4 P.O.C. - RHEL 7.X" --menu "********** Red Hat Tools Menu ********* \n Please choose [1 -> 6]?" 30 90 10 \
1 "INSTALL SATELLITE 6.4" \
2 "UPGRADE/UPDATE THE SATELLITE 6.X" \
3 "SYNC ALL ACTIVATED REPOSITORIES" \
4 "LATEST ANSIBLE TOWER INSTALL" \
5 "POST INSTALL CLEANUP" \
6 "EXIT"
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
1) dMsgBx "INSTALL SATELLITE 6.4" \
VARIABLES1
DEFAULTMSG
SYNCREL5
SYNCREL6
INSTALLREPOS
INSTALLDEPS
GENERALSETUP
SYSCHECK
INSTALLNSAT
CONFSAT
HAMMERCONF
CONFIG2
STOPSPAMMINGVARLOG
REQUESTSYNCMGT
REQUESTPUPPET
REQUEST6
REQUEST7
REQUESTCENTOS7
SYNC
SYNCMSG
PRIDOMAIN
CREATESUBNET
ENVIRONMENTRHEL7
ENVIRONMENTRHEL6
ENVIRONMENTCENTOS7
SYNCPLANS
sleep 10 
exit
;;
2) dMsgBx "UPGRADE/UPDATE THE SATELLITE 6.3^" \
SATUPDATE
INSIGHTS
;;
3) dMsgBx "SYNC ALL ACTIVATED REPOSITORIES" \
SYNC
;;
4) dMsgBx "LATEST ANSIBLE TOWER INSTALL" \
ANSIBLETOWER
;;
5)  dMsgBx "POST INSTALL CLEANUP" \
#REMOVEUNSUPPORTED
DISASSOCIATE_TEMPLATES
CLEANUP
;;
6) dMsgBx "*** EXITING - THANK YOU ***"
break
;;
esac

done

exit 0
