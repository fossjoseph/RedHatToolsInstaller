#!/bin/bash
#POC/Demo
echo -ne "\e[8;40;170t"

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
if [ "$(whoami)" != "root" ]
then
echo "This script must be run as root - if you do not have the credentials please contact your administrator"
exit
fi

#--------------------------required packages for script to run----------------------------

echo "*************************************************************"
echo " Script configuration requirements installing for this server"
echo "*************************************************************"
setenforce 0
HNAME=$(hostname)
domainname $(hostname -d)
subscription-manager register --auto-attach
subscription-manager attach --pool=`subscription-manager list --available --matches 'Red Hat Satellite Infrastructure Subscription' --pool-only`
rm -fr /var/cache/yum/*
yum clean all 
subscription-manager repos --disable "*" || exit 1
subscription-manager repos --enable=rhel-7-server-rpms || exit 1
subscription-manager repos --enable=rhel-7-server-extras-rpms || exit 1
subscription-manager repos --enable=rhel-7-server-optional-rpms || exit 1
subscription-manager repos --enable=rhel-7-server-rpms|| exit 1
yum-config-manager --enable epel
yum-config-manager --save --setopt=*.skip_if_unavailable=true
rm -fr /var/cache/yum/*
yum clean all
yum -q list installed yum-utils &>/dev/null && echo "yum-utils is installed" || yum install -y yum-util* --skip-broken
yum -q list installed epel-release-latest-7 &>/dev/null && echo "epel-release-latest-7 is installed" || yum install -y https://dl.fedoraproject.org/pub/epel/epel-release-latest-7.noarch.rpm --skip-broken
yum -q list installed gtk2-devel &>/dev/null && echo "gtk2-devel is installed" || yum install -y gtk2-devel --skip-broken
yum -q list installed wget &>/dev/null && echo "wget is installed" || yum install -y wget --skip-broken
yum -q list installed firewalld &>/dev/null && echo "firewalld is installed" || yum install -y firewalld --skip-broken
yum -q list installed ansible &>/dev/null && echo "ansible is installed" || yum install -y ansible --skip-broken 
yum -q list installed gnome-terminal &>/dev/null && echo "gnome-terminal is installed" || yum install -y gnome-terminal --skip-broken
yum -q list installed yum &>/dev/null && echo "yum is installed" || yum install -y yum --skip-broken
yum -q list installed lynx &>/dev/null && echo "lynx is installed" || yum install -y lynx --skip-broken
yum -q list installed perl &>/dev/null && echo "perl is installed" || yum install -y perl --skip-broken
yum -q list installed dialog &>/dev/null && echo "dialog is installed" || yum install -y *dialog* --skip-broken
yum -q list installed xdialog &>/dev/null && echo "xdialog is installed" || yum install -y xdialog --skip-broken
yum install -y dconf*
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
# If Display is no set assume ok to use dialog
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

#------------------
function NETWORK {
#------------------
eth0_provision=1
eth1_provision=1

if [ $? -eq 0 ]; then
eth0_provision=1
else
eth1_provision=1
fi
flag2=1
while [ $flag2 -eq 1 ]; do
echo " "
-n "Current Host Name: "
"$HOSTNAME"
"Current Network Settings: "
if [$eth0_provision -eq 1]; then
"1. eth0 (provision network): "
else
"1. eth0 (public network): "
fi
cat /etc/sysconfig/network-scripts/ifcfg-eth0 | grep IPADDR |  sed 's/IPADDR=/IP address: /'
cat /etc/sysconfig/network-scripts/ifcfg-eth0 | grep NETMASK |  sed 's/NETMASK=/Netmask: /'
if [ $eth0_provision -eq 1 ]; then
" "
"2. eth1 (public network): "
else
" "
"2. eth1 (provision network): "
fi
cat /etc/sysconfig/network-scripts/ifcfg-eth1 | grep IPADDR |  sed 's/IPADDR=/IP address: /'
cat /etc/sysconfig/network-scripts/ifcfg-eth1 | grep NETMASK |  sed 's/NETMASK=/Netmask: /'

" "
-n "Current Default Gateway: "
cat /etc/sysconfig/network | grep GATEWAY | sed 's/GATEWAY=//'
" "
-n "Current Name Server: "
cat /etc/resolv.conf | grep nameserver | awk '{print $2}'
" "
dYesNo "Would you like to change the settings?(y/n) " 
RC=$?
if [[ $RC == 0 ]]
then

# Get and validate new host name
host_name_flag=1
while [ $host_name_flag -eq 1 ]; do
OutPut=$(mktemp $TMPd/host_name.$$.XXXXXX)
dInptBx "HostName"  "Please input fully qualified host name."  "management.domain.com" 2> $OutPut
read host_name < $OutPut
rm $OutPut
HOSTNAME_VAL=`echo $host_name | grep -Ec '^(([a-zA-Z]|[a-zA-Z][a-zA-Z0-9]*[a-zA-Z0-9])\.)+([A-Za-z]|[A-Za-z][A-Za-z0-9]*[A-Za-z0-9])$'`
if [ $HOSTNAME_VAL == 0 ]; then
dMsgBx "Bad host name: $host_name. Please check host name format."
else
host_name_flag=0
fi
done
rm -rf /etc/sysconfig/network.new > /dev/null
touch /etc/sysconfig/network.new
"NETWORKING=yes" >> /etc/sysconfig/network.new
"HOSTNAME=$host_name" >> /etc/sysconfig/network.new
mv -f /etc/sysconfig/network.new /etc/sysconfig/network

# Get and validate new network settings
if [ $eth0_provision -eq 1 ]; then
"1. eth0 (provision network): "
else
"1. eth0 (public network): "
fi
eth0_IP_flag=1
while [ $eth0_IP_flag -eq 1 ]; do
OutPut=$(mktemp $TMPd/eth0ip.$$.XXXXXX)
dInptBx "Eth0 IP"  "Please input IP Address of eth0:"  "10.172.192.168" 2> $OutPut
read eth0_IP < $OutPut
rm $OutPut
IP_ADDR_VAL=`echo $eth0_IP | grep -Ec '^(([0-9]|[1-9][0-9]|1[0-9]{2}|2[0-4][0-9]|25[0-5])\.){3}([0-9]|[1-9][0-9]|1[0-9]{2}|2[0-4][0-9]|25[0-5])$'`
if [ $IP_ADDR_VAL == 0 ]; then
dMsgBx "Bad IP address: $eth0_IP. Please check IP address format."
else
eth0_IP_flag=0
fi
done
  
eth0_netmask_flag=1
while [ $eth0_netmask_flag -eq 1 ]; do
OutPut=$(mktemp $TMPd/eth0nm.$$.XXXXXX)
dInptBx "Eth0 Netmask"  "Please input the NetMask eth0:"  "255.255.0.0" 2> $OutPut
read eth0_netmask < $OutPut
rm $OutPut
NETMASK_VAL=`echo $eth0_netmask | grep -Ec '^(([0-9]|[1-9][0-9]|1[0-9]{2}|2[0-4][0-9]|25[0-5])\.){3}([0-9]|[1-9][0-9]|1[0-9]{2}|2[0-4][0-9]|25[0-5])$'`
if [ $NETMASK_VAL == 0 ]; then
dMsgBx "Bad Netmask: $eth0_netmask. Please check netmask format."
else
eth0_netmask_flag=0
fi
done

rm -rf $TMPd/ifcfg-eth0.new
touch $TMPd/ifcfg-eth0.new
"DEVICE=eth0" >> $TMPd/ifcfg-eth0.new
"IPADDR=$eth0_IP" >> $TMPd/ifcfg-eth0.new
"NETMASK=$eth0_netmask" >> $TMPd/ifcfg-eth0.new
"BOOTPROTO=static" >> $TMPd/ifcfg-eth0.new
"NM_CONTROLLED=no" >> $TMPd/ifcfg-eth0.new
"ONBOOT=yes" >> $TMPd/ifcfg-eth0.new
mv -f $TMPd/ifcfg-eth0.new /etc/sysconfig/network-scripts/ifcfg-eth0
  

if [ $eth0_provision -eq 1 ]; then
"2. eth1 (public network): "
else
"2. eth1 (provision network): "
fi
eth1_IP_flag=1
while [ $eth1_IP_flag -eq 1 ]; do
OutPut=$(mktemp $TMPd/eth1ip.$$.XXXXXX)
dInptBx "Eth0 IP"  "Please input IP Address of eth1:"  "10.172.192.168" 2> $OutPut
read eth1_IP < $OutPut
rm $OutPut
IP_ADDR_VAL=`echo $eth1_IP | grep -Ec '^(([0-9]|[1-9][0-9]|1[0-9]{2}|2[0-4][0-9]|25[0-5])\.){3}([0-9]|[1-9][0-9]|1[0-9]{2}|2[0-4][0-9]|25[0-5])$'`
if [ $IP_ADDR_VAL == 0 ]; then
dMsgBx "Bad IP address: $eth1_IP. Please check IP address format."
else
eth1_IP_flag=0
fi
done

eth1_netmask_flag=1
while [ $eth1_netmask_flag -eq 1 ]; do
OutPut=$(mktemp $TMPd/eth1nm.$$.XXXXXX)
dInptBx "Eth1 Netmask"  "Please input NetMask of eth1:"  "255.255.0.0" 2> $OutPut
read eth1_netmask < $OutPut
rm $OutPut
NETMASK_VAL=`echo $eth1_netmask | grep -Ec '^(([0-9]|[1-9][0-9]|1[0-9]{2}|2[0-4][0-9]|25[0-5])\.){3}([0-9]|[1-9][0-9]|1[0-9]{2}|2[0-4][0-9]|25[0-5])$'`
if [ $NETMASK_VAL == 0 ]; then
dMsgBx "Bad Netmask: $eth1_netmask. Please check netmask format."
else
eth1_netmask_flag=0
fi
done

rm -rf $TMPd/ifcfg-eth1.new
touch $TMPd/ifcfg-eth1.new
"DEVICE=eth1" >> $TMPd/ifcfg-eth1.new
"IPADDR=$eth1_IP" >> $TMPd/ifcfg-eth1.new
"NETMASK=$eth1_netmask" >> $TMPd/ifcfg-eth1.new
"BOOTPROTO=static" >> $TMPd/ifcfg-eth1.new
"NM_CONTROLLED=no" >> $TMPd/ifcfg-eth1.new
"ONBOOT=yes" >> $TMPd/ifcfg-eth1.new
mv -f $TMPd/ifcfg-eth1.new /etc/sysconfig/network-scripts/ifcfg-eth1

# Default Gateway
default_gateway_flag=1
while [ $default_gateway_flag -eq 1 ]; do
OutPut=$(mktemp $TMPd/def_gw.$$.XXXXXX)
dInptBx "Eth0 Netmask"  "Please input Default Gateway of Installer Node::"  "123.123.125.255" 2> $OutPut
read default_gateway < $OutPut
rm $OutPut
GATEWAY_VAL=`echo $default_gateway | grep -Ec '^(([0-9]|[1-9][0-9]|1[0-9]{2}|2[0-4][0-9]|25[0-5])\.){3}([0-9]|[1-9][0-9]|1[0-9]{2}|2[0-4][0-9]|25[0-5])$'`
if [ $GATEWAY_VAL == 0 ]; then
dMsgBx "Bad Default Gateway: $default_gateway. Please check default gateway format."
else
default_gateway_flag=0
fi
done
"GATEWAY=$default_gateway" >> /etc/sysconfig/network

# DNS change
dns_flag=1
while [ $dns_flag -eq 1 ]; do
OutPut=$(mktemp $TMPd/name_server.$$.XXXXXX)
dInptBx "DNS"  "Please input name server IP Address:"  "255.255.0.0" 2> $OutPut
read name_server < $OutPut
rm $OutPut
DNS_VAL=`echo $name_server | grep -Ec '^(([0-9]|[1-9][0-9]|1[0-9]{2}|2[0-4][0-9]|25[0-5])\.){3}([0-9]|[1-9][0-9]|1[0-9]{2}|2[0-4][0-9]|25[0-5])$'`
if [ $DNS_VAL == 0 ]; then
dMsgBx "Bad name server IP address: $name_server. Please check name server IP address format."
else
dns_flag=0
fi
done
rm -rf /etc/resolv.conf.new > /dev/null
touch /etc/resolv.conf.new
"nameserver $name_server" >> /etc/resolv.conf.new
"domain $DOMAIN"  >> /etc/resolv.conf.new
echo "search $DOMAIN"  >> /etc/resolv.conf.new
mv -f /etc/resolv.conf.new /etc/resolv.conf

else
flag2=0
fi
done
}

#-----------------------------------------------------------------------------------------------------------------------
#-----------------------------------------Stage 1 - Install Satellite 6.x-----------------------------------------------
#-----------------------------------------------------------------------------------------------------------------------
#-------------------------------
function VARIABLES1 {
#-------------------------------
echo "*********************************************************"
echo "COLLECT VARIABLES FOR SAT 6.X"
echo "*********************************************************"
export INTERNAL=$(ip -o link | head -n 2 | tail -n 1 | awk '{print $2}' | sed s/:// )
export EXTERNAL=$(ip route show | sed -e 's/^default via [0-9.]* dev \(\w\+\).*/\1/' | head -1)
export INTERNALIP=$(ifconfig "$INTERNAL" | grep "inet" | awk -F ' ' '{print $2}' |grep -v f |awk -F . '{print $1"."$2"."$3"."$4}')
export INTERNALSUBMASK=$(ifconfig "$INTERNAL" |grep netmask |awk -F " " {'print $4'})
export INTERNALGATEWAY=$(ip route list type unicast dev $(ip -o link | head -n 2 | tail -n 1 | awk '{print $2;}' | sed s/:$//) |awk -F " " '{print $7}')
echo "INTERNALIP=$INTERNALIP" >> /root/.bashrc
echo "*********************************************************"
echo "ORGANIZATION"
echo "*********************************************************"
echo 'What is the name of your Organization?'
read ORG
echo 'ORG='$ORG'' >> /root/.bashrc
echo "*********************************************************"
echo "LOCATION OF YOUR SATELLITE"
echo "*********************************************************"
echo 'LOCATION'
echo 'What is the location of your Satellite server. Example DENVER'
read LOC
echo 'LOC='$LOC'' >> /root/.bashrc
echo "*********************************************************"
echo "SETTING DOMAIN"
echo "*********************************************************"
echo 'what is your domain name Example:'$(hostname -d)''
read DOM
echo 'DOM='$DOM'' >> /root/.bashrc
echo "*********************************************************"
echo "ADMIN PASSWORD"
echo "*********************************************************"
echo 'ADMIN=admin'  >> /root/.bashrc
echo 'What will the password be for your admin user?'
read  ADMIN_PASSWORD
echo 'ADMIN_PASSWORD='$ADMIN_PASSWORD'' >> /root/.bashrc
echo "*********************************************************"
echo "NAME OF FIRST SUBNET"
echo "*********************************************************"
echo 'What would you like to call your first subnet for systems you are regestering to satellite?'
read  SUBNET
echo 'SUBNET_NAME='$SUBNET'' >> /root/.bashrc
echo "*********************************************************"
echo "PROVISIONED NODE PREFIX"
echo "*********************************************************"
# The host prefix is used to distinguish the demo hosts created at the end of this script.
echo 'What would you like the prefix to be for systems you are provisioning with Satellite Example poc- kvm- vm-? enter to skip'
read  PREFIX
echo 'HOST_PREFIX='$PREFIX'' >> /root/.bashrc
echo "*********************************************************"
echo "NODE PASSWORD"
echo "*********************************************************"
echo 'PROVISIONED HOST PASSWORD'
echo 'Please enter the default password you would like to use for root for your newly provisioned nodes'
read PASSWORD
for i in $(echo "$PASSWORD" | openssl passwd -apr1 -stdin); do echo NODEPASS=$i >> /root/.bashrc ; done

export "DHCPSTART=$(ifconfig $INTERNAL | grep "inet" | awk -F ' ' '{print $2}' |grep -v f |awk -F . '{print $1"."$2"."$3"."2}')"
export "DHCPEND=$(ifconfig $INTERNAL | grep "inet" | awk -F ' ' '{print $2}' |grep -v f |awk -F . '{print $1"."$2"."$3"."254}')"
echo "*********************************************************"
echo "FINDING NETWORK"
echo "*********************************************************"
echo 'INTERNALNETWORK='$(ifconfig "$INTERNAL" | grep "inet" | awk -F ' ' '{print $2}' |grep -v f |awk -F . '{print $1"."$2"."0"."0}')'' >> /root/.bashrc
echo "*********************************************************"
echo "FINDING SAT INTERFACE"
echo "*********************************************************"
echo 'SAT_INTERFACE='$(ip -o link | head -n 2 | tail -n 1 | awk '{print $2;}' | sed s/:$//)'' >> /root/.bashrc
echo "*********************************************************"
echo "FINDING SAT IP"
echo "*********************************************************"
echo 'SAT_IP='$(ifconfig "$INTERNAL" | grep "inet" | awk -F ' ' '{print $2}' |grep -v f |awk -F . '{print $1"."$2"."$3"."$4}')'' >> /root/.bashrc
echo "*********************************************************"
echo "FINDING SAT DOMAIN"
echo "*********************************************************"
echo 'DOM='$(hostname -d)'' >> /root/.bashrc
echo "*********************************************************"
echo "SETTING RELM"
echo "*********************************************************"
echo 'REALM='$(hostname -d)'' >> /root/.bashrc
echo "*********************************************************"
echo "SETTING DNS"
echo "*********************************************************"
echo 'DNS='$(ip route list type unicast dev $(ip -o link | head -n 2 | tail -n 1 | awk '{print $2;}' | sed s/:$//) |awk -F " " '{print $7}')'' >> /root/.bashrc
echo 'DNS_REV='$(ifconfig $INTERNAL | grep "inet" | awk -F ' ' '{print $2}' |grep -v f |awk -F . '{print $3"."$2"."$1".""in-addr.arpa"}')'' >> /root/.bashrc
echo "*********************************************************"
echo "DNS PTR RECORD"
echo "*********************************************************"
'PTR='$(ifconfig "$INTERNAL" | grep "inet" | awk -F ' ' '{print $2}' |grep -v f |awk -F . '{print $4}')''  >> /root/.bashrc
echo "*********************************************************"
echo "SETTING SUBNET VARS"
echo "*********************************************************"
echo 'SUBNET='$(ifconfig $INTERNAL | grep "inet" | awk -F ' ' '{print $2}' |grep -v f |awk -F . '{print $1"."$2"."0"."0}')'' >> /root/.bashrc
echo 'SUBNET_MASK='$(ifconfig $INTERNAL |grep netmask |awk -F " " {'print $4'})'' >> /root/.bashrc
echo "*********************************************************"
echo "SETTING BGIN AND END IPAM RANGE"
echo "*********************************************************"
echo 'SETTING BEGIN AND END IPAM RANGE'
echo 'SUBNET_IPAM_BEGIN='$DHCPSTART'' >> /root/.bashrc
echo 'SUBNET_IPAM_END='$DHCPEND'' >> /root/.bashrc
echo "*********************************************************"
echo "DHCP"
echo "*********************************************************"
echo 'DHCP_RANGE=''"'$DHCPSTART' '$DHCPEND'"''' >> /root/.bashrc
echo 'DHCP_GW='$(ip route list type unicast dev $(ip -o link | head -n 2 | tail -n 1 | awk '{print $2;}' | sed s/:$//) |awk -F " " '{print $7}')'' >> /root/.bashrc
echo 'DHCP_DNS='$(ifconfig $INTERNAL | grep "inet" | awk -F ' ' '{print $2}' |grep -v f |awk -F . '{print $1"."$2"."$3"."$4}')'' >> /root/.bashrc
}

YMESSAGE="Adding to /root/.bashrc vars"
NMESSAGE="Skipping"
FMESSAGE="PLEASE ENTER Y or N"
COUNTDOWN=10
DEFAULTVALUE=n
#-------------------------------
function IPA {
#-------------------------------
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
read -p "Press [Enter] to continue"
#init 6
}
#---END OF VARIABLES 1 SCRIPT---

#Reboot your system at this point so that the system will see the variable in /root/.bashrc by default
#init 6
#CHECK YOUR VARIABLES!!!
#vim /root/.bashrc
#Now that the system is registered and some variables are available you need to configure a couple components so that satellite can be installed 

#sudo su
#---START OF SAT 6.X INSTALL SCRIPT---
#------------------------------
function INSTALLREPOS {
#------------------------------
echo "*********************************************************"
echo "SET REPOS FOR INSTALLING AND UPDATING SATELLITE 6.4"
echo "*********************************************************"
echo -ne "\e[8;40;170t"
rpm -Uvh https://dl.fedoraproject.org/pub/epel/epel-release-latest-7.noarch.rpm || true
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
echo "*********************************************************"
echo "INSTALLING DEPENDENCIES"
echo "*********************************************************"
echo -ne "\e[8;40;170t"
yum-config manager --enable epel
sleep 5
yum install -y screen yum-utils vim gcc gcc-c++ git rh-nodejs8-npm make automake kernel-devel ruby-devel libvirt-client bind dhcp tftp 
sleep 5
yum -y install python-pip rubygem-builder
yum-config manager --disable epel
pip install --upgrade pip
yum clean all ; rm -rf /var/cache/yum
yum upgrade -y; yum update -y
}
#----------------------------------
function GENERALSETUP {
#----------------------------------
echo "*********************************************************"
echo 'GENERAL SETUP'
echo "*********************************************************"
echo -ne "\e[8;40;170t"
source /root/.bashrc
echo "*********************************************************"
echo "GENERATE USERS AND SYSTEM KEYS FOR REQUIRED USERS"
echo "*********************************************************"
echo "*********************************************************"
echo "ADMIN"
echo "*********************************************************"
useradd admin --group admin -m -p $ADMIN
mkdir -p /home/admin/.ssh
mkdir -p /home/admin/git
chown -R admin:admin /home/admin
sudo -u admin ssh-keygen -f /home/admin/.ssh/id_rsa -N ''
echo "*********************************************************"
echo "FOREMAN-PROXY"
echo "*********************************************************"
useradd -M foreman-proxy
usermod -L foreman-proxy
mkdir -p /usr/share/foreman-proxy/.ssh
sudo -u foreman-proxy ssh-keygen -f /usr/share/foreman-proxy/.ssh/id_rsa_foreman_proxy -N ''
chown -R foreman-proxy:foreman-proxy /usr/share/foreman-proxy
echo "*********************************************************"
echo "ROOT"
echo "*********************************************************"
ssh-keygen -f /root/.ssh/id_rsa -t rsa -N ''
echo "*********************************************************"
echo “SET DOMAIN”
echo "*********************************************************"
echo 'inet.ipv4.ip_forward=1' >> /etc/sysctl.conf
echo "kernel.domainname=$DOM" >> /etc/sysctl.conf
echo "*********************************************************"
echo "GENERATE /ETC/HOSTS"
echo "*********************************************************"
echo "${SAT_IP} $(hostname)" >>/etc/hosts
echo "*********************************************************"
echo "ADDING KATELLO-CVMANAGER TO /HOME/ADMIN/GIT "
echo "*********************************************************"
cd /home/admin/git
git clone https://github.com/RedHatSatellite/katello-cvmanager.git
cd 
echo "*********************************************************"
echo "SET SELINUX TO PERMISSIVE FOR THE INSTALL AND CONFIG OF SATELLITE"
echo "*********************************************************"
sed -i 's/SELINUX=enforcing/SELINUX=permissive/g' /etc/selinux/config
setenforce 0
echo "*********************************************************"
echo "SETTING ADMIN USER TO NO PASSWORD FOR SUDO"
echo "*********************************************************"
echo 'admin ALL = NOPASSWD: ALL' >> /etc/sudoers
echo "*********************************************************"
echo "ADDING REQUIRED DIRECTORIES"
echo "*********************************************************"
mkdir -p /root/Downloads
mkdir -p /root/.hammer
}
#  --------------------------------------
function INSTALLNSAT {
#  --------------------------------------
echo "*********************************************************"
echo "INSTALL SATELLITE"
echo "*********************************************************"
echo -ne "\e[8;40;170t"
source /root/.bashrc
yum-config-manager --disable epel
subscription-manager repos --enable=rhel-7-server-rpms || exit 1
subscription-manager repos --enable=rhel-server-rhscl-7-rpms || exit 1
subscription-manager repos --enable=rhel-7-server-optional-rpms || exit 1
subscription-manager repos --enable=rhel-7-server-satellite-6.4-rpms || exit 1
subscription-manager repos --enable=rhel-7-server-satellite-maintenance-6-rpms || exit 1
yum clean all 
rm -rf /var/cache/yum

yum -q list installed satellite &>/dev/null && echo "satellite is installed" || time yum install satellite -y --skip-broken
yum -q list installed puppetserver &>/dev/null && echo "puppetserver is installed" || time yum install puppetserver -y --skip-broken
yum -q list installed puppet-agent-oauth &>/dev/null && echo "puppet-agent-oauth is installed" || time yum install puppet-agent-oauth -y --skip-broken
yum -q list installed puppet-agent &>/dev/null && echo "puppet-agent is installed" || time yum install puppet-agent -y --skip-broken


}
#---END OF SAT 6.X INSTALL SCRIPT---

#Reboot again here !!
#init 6

#---START OF SAT 6.X CONFIGURE SCRIPT---
#  --------------------------------------
function CONFSAT {
#  --------------------------------------
source /root/.bashrc
echo -ne "\e[8;40;170t"
echo "*********************************************************"
echo "CONFIGURING SATELLITE"
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
--foreman-proxy-dns-tsig-principal="foreman-proxy $(hostname)@$DOM" \
--foreman-proxy-dns-tsig-keytab=/etc/foreman-proxy/dns.key \
--foreman-proxy-dns-interface $SAT_INTERFACE \
--foreman-proxy-dns-zone=$DOM \
--foreman-proxy-dns-forwarders $DNS \
--foreman-proxy-dns-reverse $DNS_REV \
--foreman-proxy-dhcp true \
--foreman-proxy-dhcp-server $INTERNALIP \
--foreman-proxy-dhcp-interface=$SAT_INTERFACE \
--foreman-proxy-dhcp-range="$DHCP_RANGE" \
--foreman-proxy-dhcp-gateway=$DHCP_GW \
--foreman-proxy-dhcp-nameservers $DHCP_DNS \
--foreman-proxy-tftp true \
--foreman-proxy-tftp-servername=$(hostname) \
--enable-foreman-plugin-openscap

foreman-rake apipie:cache:index --trace
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
 :host: 'https://$(hostname)'
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
echo "*********************************************************"
echo "UPLOAD THE SATELLITE MANIFEST"
echo "The Satellite Manifest can be in the Red Hat customer portal at https://access.redhat.com/management/subscription_allocations:"
echo "*********************************************************"
firefox https://access.redhat.com/management/subscription_allocations -y &
read -p "Press [Enter] to continue"
sleep 5
echo ' '
echo ' '
echo 'what is the full path to your Satellite Manifest? Example: /root/manifest*.zip'
read SATMAN 
time hammer subscription upload --organization $ORG --file $SATMAN
sleep 20
#time hammer subscription refresh-manifest --organization $ORG
#sleep 20
#for i in $(hammer capsule list |awk -F '|' '{print $1}' |grep -v ID|grep -v -) ; do hammer capsule refresh-features --id=$i ; done 
hammer settings set --name default_download_policy --value on_demand
hammer settings set --name default_organization  --value $ORG
hammer settings set --name default_location  --value $LOC
hammer settings set --name discovery_organization  --value $ORG
hammer settings set --name discovery_organization  --value $ORG
hammer settings set --name root_pass --value $NODEPASS
yum install -y puppet-foreman_scap_client
yum install -y foreman-discovery-image
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
echo "*********************************************************"
echo "Configure Repositories"
echo "*********************************************************"
#NOTE: Jenkins, CentOS-7  Puppet Forge, Icinga, and Maven are examples of setting up a custom repository
#---START OF REPO CONFIGURE AND SYNC SCRIPT---
source /root/.bashrc
QMESSAGE5="Would you like to enable and sync RHEL 5 Content
This will enable
 Red Hat Enterprise Linux 5 Server (Kickstart)
 Red Hat Enterprise Linux 5 Server
 Red Hat Satellite Tools 6.4 (for RHEL 5 Server)
 Red Hat Software Collections RPMs for Red Hat Enterprise Linux 5 Server
 Red Hat Enterprise Linux 5 Server - Extras
 Red Hat Enterprise Linux 5 Server - Optional
 Red Hat Enterprise Linux 5 Server - Supplementary
 Red Hat Enterprise Linux 5 Server - RH Common
 Extra Packages for Enterprise Linux 5"

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

QMESSAGE7="Would you like to enable and sync RHEL 7 Content
This will enable:
 Red Hat Enterprise Linux 7 Server (Kickstart)
 Red Hat Enterprise Linux 7 Server
 Red Hat Satellite Tools 6.4 (for RHEL 7 Server)
 Red Hat Software Collections RPMs for Red Hat Enterprise Linux 7 Server
 Red Hat Enterprise Linux 7 Server - Extras
 Red Hat Enterprise Linux 7 Server - Optional
 Red Hat Enterprise Linux 7 Server - Supplementary
 Red Hat Enterprise Linux 7 Server - RH Common
 Extra Packages for Enterprise Linux 7"
QMESSAGERHSCL="Would you like to download Red Hat Software Collections RPMs for Red Hat Enterprise Linux 7 Server x86_64 7Server content"
QMESSAGEJBOSS="Would you like to download JBoss Enterprise Application Platform 7 (RHEL 7 Server) content"
QMESSAGEVIRTAGENT="Would you like to download Red Hat Virtualization 4 Management Agents for RHEL 7 content"
QMESSAGESAT64="Would you like to download Red Hat Satellite 6.4 (for RHEL 7 Server) content"
QMESSAGECAP64="Would you like to download Red Hat Satellite Capsule 6.4 (for RHEL 7 Server) content"
QMESSAGEOSC="Would you like to download Red Hat OpenShift Container Platform 3.10 content"
QMESSAGECEPH="Would you like to download Red Hat Ceph Storage Tools 3.0 for Red Hat Enterprise Linux 7 Server content"
QMESSAGESNC="Would you like to download Red Hat Storage Native Client for RHEL 7 content"
QMESSAGECSI="Would you like to download Red Hat Ceph Storage Installer 3.0 for Red Hat Enterprise Linux 7 Server content"
QMESSAGEOSP="Would you like to download Red Hat OpenStack Platform 13 for RHEL 7 content"
QMESSAGEOSPT="Would you like to download Red Hat OpenStack Tools 7.0 for Red Hat Enterprise Linux 7 Server content"
QMESSAGERHVH="Would you like to download Red Hat Virtualization Host 7 content"
QMESSAGERHVM="Would you like to download Red Hat Virtualization Manager 4.2 (RHEL 7 Server) content"
QMESSAGEATOMIC="Would you like to download Red Hat Enterprise Linux Atomic Host content"
QMESSAGETOWER="Would you like to download Ansible Tower custom content"
QMESSAGEPUPPET="Would you like to download Puppet Forge custom content"
QMESSAGEJENKINS="Would you like to download JENKINS custom content"
QMESSAGEMAVEN="Would you like to download Maven custom content"
QMESSAGEICINGA="Would you like to download Icinga custom content"
QMESSAGECENTOS7="Would you like to download CentOS-7 custom content"

YMESSAGE="Adding avalable content"
NMESSAGE="Skipping avalable content"
FMESSAGE="PLEASE ENTER Y or N"
COUNTDOWN=15
DEFAULTVALUE=n
#-------------------------------
function REQUEST5 {
#-------------------------------
source /root/.bashrc
echo -ne "\e[8;40;170t"
echo "*********************************************************"
echo "RHEL 5 STANDARD REPOS:"
echo "*********************************************************"
read -n1 -t$COUNTDOWN -p "$QMESSAGE5 ? Y/N " INPUT
INPUT=${INPUT:-$DEFAULTVALUE}
if  [ "$INPUT" = "y" -o "$INPUT" = "Y" ] ;then
echo -e "\n$YMESSAGE\n"
hammer repository-set enable --organization $ORG --product 'Red Hat Enterprise Linux Server' --basearch='x86_64' --releasever='5.11' --name 'Red Hat Enterprise Linux 5 Server (Kickstart)'
hammer repository update --organization $ORG --product 'Red Hat Enterprise Linux Server' --name 'Red Hat Enterprise Linux 5 Server (Kickstart)' --download-policy immediate
hammer repository-set enable --organization $ORG --product 'Red Hat Enterprise Linux Server' --basearch='x86_64' --releasever='5Server' --name 'Red Hat Enterprise Linux 5 Server (RPMs)'
hammer repository-set enable --organization $ORG --product 'Red Hat Enterprise Linux Server' --basearch='x86_64' --name 'Red Hat Satellite Tools 6.4 (for RHEL 5 Server) (RPMs)'
hammer repository-set enable --organization $ORG --product 'Red Hat Software Collections for RHEL Server' --basearch='x86_64' --releasever='5Server' --name 'Red Hat Software Collections RPMs for Red Hat Enterprise Linux 5 Server'
hammer repository-set enable --organization $ORG --product 'Red Hat Enterprise Linux Server' --basearch='x86_64' --name 'Red Hat Enterprise Linux 5 Server - Extras (RPMs)'
hammer repository-set enable --organization $ORG --product 'Red Hat Enterprise Linux Server' --basearch='x86_64' --releasever='5Server' --name 'Red Hat Enterprise Linux 5 Server - Optional (RPMs)'
hammer repository-set enable --organization $ORG --product 'Red Hat Enterprise Linux Server' --basearch='x86_64' --releasever='5Server' --name 'Red Hat Enterprise Linux 5 Server - Supplementary (RPMs)'
hammer repository-set enable --organization $ORG --product 'Red Hat Enterprise Linux Server' --basearch='x86_64' --releasever='5Server' --name 'Red Hat Enterprise Linux 5 Server - RH Common (RPMs)'
wget -q https://dl.fedoraproject.org/pub/epel/RPM-GPG-KEY-EPEL-5 /root/RPM-GPG-KEY-EPEL-5
sleep 10
hammer gpg create --key /root/RPM-GPG-KEY-EPEL-5 --name 'GPG-EPEL-5' --organization $ORG
sleep 10
hammer product create --name='Extra Packages for Enterprise Linux 5' --organization $ORG
sleep 10
hammer repository create --name='Extra Packages for Enterprise Linux 5' --organization $ORG --product='Extra Packages for Enterprise Linux 5' --content-type=yum --publish-via-http=true --url=https://archives.fedoraproject.org/pub/archive/epel/5/x86_64/ --checksum-type=sha256 --gpg-key=GPG-EPEL-5
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
function REQUEST6 {
#-------------------------------
source /root/.bashrc
echo -ne "\e[8;40;170t"
echo "*********************************************************"
echo "RHEL 6 STANDARD REPOS:"
echo "*********************************************************"
read -n1 -t$COUNTDOWN -p "$QMESSAGE6 ? Y/N " INPUT
INPUT=${INPUT:-$DEFAULTVALUE}
if  [ "$INPUT" = "y" -o "$INPUT" = "Y" ] ;then
echo -e "\n$YMESSAGE\n"
hammer repository-set enable --organization $ORG --product 'Red Hat Enterprise Linux Server' --basearch='x86_64' --releasever='6.10' --name 'Red Hat Enterprise Linux 6 Server (Kickstart)' 
hammer repository update --organization $ORG --product 'Red Hat Enterprise Linux Server' --basearch='x86_64' --releasever='6.10' --name 'Red Hat Enterprise Linux 6 Server (Kickstart)' --download-policy immediate
hammer repository update --organization $ORG --product
hammer repository-set enable --organization $ORG --product 'Red Hat Enterprise Linux Server' --basearch='x86_64' --releasever='6Server' --name 'Red Hat Enterprise Linux 6 Server (RPMs)'
hammer repository-set enable --organization $ORG --product 'Red Hat Enterprise Linux Server' --basearch='x86_64' --name 'Red Hat Satellite Tools 6.4 (for RHEL 6 Server) (RPMs)'
hammer repository-set enable --organization $ORG --product 'Red Hat Software Collections for RHEL Server' --basearch='x86_64' --releasever='6Server' --name 'Red Hat Software Collections RPMs for Red Hat Enterprise Linux 6 Server'
hammer repository-set enable --organization $ORG --product 'Red Hat Enterprise Linux Server' --basearch='x86_64' --name 'Red Hat Enterprise Linux 6 Server - Extras (RPMs)'
hammer repository-set enable --organization $ORG --product 'Red Hat Enterprise Linux Server' --basearch='x86_64' --releasever='6Server' --name 'Red Hat Enterprise Linux 6 Server - Optional (RPMs)'
hammer repository-set enable --organization $ORG --product 'Red Hat Enterprise Linux Server' --basearch='x86_64' --releasever='6Server' --name 'Red Hat Enterprise Linux 6 Server - Supplementary (RPMs)'
hammer repository-set enable --organization $ORG --product 'Red Hat Enterprise Linux Server' --basearch='x86_64' --releasever='6Server' --name 'Red Hat Enterprise Linux 6 Server - RH Common (RPMs)'
wget -q https://dl.fedoraproject.org/pub/epel/RPM-GPG-KEY-EPEL-6 -O /root/RPM-GPG-KEY-EPEL-6
sleep 10
hammer gpg create --key /root/RPM-GPG-KEY-EPEL-6 --name 'GPG-EPEL-6' --organization $ORG
sleep 10
hammer product create --name='Extra Packages for Enterprise Linux 6' --organization $ORG
sleep 10
hammer repository create --name='Extra Packages for Enterprise Linux 6' --organization $ORG --product='Extra Packages for Enterprise Linux 6' --content-type=yum --publish-via-http=true --url=http://dl.fedoraproject.org/pub/epel/6/x86_64/ --checksum-type=sha256 --gpg-key=GPG-EPEL-6
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
function REQUEST7 {
#-------------------------------
source /root/.bashrc
echo -ne "\e[8;40;170t"
echo "*********************************************************"
echo "RHEL 7 STANDARD REPOS:"
echo "*********************************************************"
read -n1 -t$COUNTDOWN -p "$QMESSAGE7 ? Y/N " INPUT
INPUT=${INPUT:-$DEFAULTVALUE}
if  [ "$INPUT" = "y" -o "$INPUT" = "Y" ] ;then
echo -e "\n$YMESSAGE\n"
hammer repository-set enable --organization $ORG --product 'Red Hat Enterprise Linux Server' --basearch='x86_64' --releasever='7.6' --name 'Red Hat Enterprise Linux 7 Server (Kickstart)' 
hammer repository update --organization $ORG --product 'Red Hat Enterprise Linux Server' --name 'Red Hat Enterprise Linux 7 Server Kickstart x86_64 7.6' --download-policy immediate
hammer repository-set enable --organization $ORG --product 'Red Hat Enterprise Linux Server' --basearch='x86_64' --releasever='7Server' --name 'Red Hat Enterprise Linux 7 Server (RPMs)'
hammer repository-set enable --organization $ORG --product 'Red Hat Software Collections for RHEL Server' --basearch='x86_64' --releasever='7Server' --name 'Red Hat Software Collections RPMs for Red Hat Enterprise Linux 7 Server' 
hammer repository-set enable --organization $ORG --product 'Red Hat Enterprise Linux Server' --basearch='x86_64' --name 'Red Hat Enterprise Linux 7 Server - Extras (RPMs)'
hammer repository-set enable --organization $ORG --product 'Red Hat Enterprise Linux Server' --basearch='x86_64' --releasever='7Server' --name 'Red Hat Enterprise Linux 7 Server - Optional (RPMs)'
hammer repository-set enable --organization $ORG --product 'Red Hat Enterprise Linux Server' --basearch='x86_64' --releasever='7Server' --name 'Red Hat Enterprise Linux 7 Server - RH Common (RPMs)'
hammer repository-set enable --organization $ORG --product 'Red Hat Enterprise Linux Server' --basearch='x86_64' --releasever='7Server' --name 'Red Hat Enterprise Linux 7 Server - Supplementary (RPMs)'
hammer repository-set enable --organization $ORG --product 'Red Hat Enterprise Linux Server' --basearch='x86_64' --releasever='7Server' --name 'Red Hat Ceph Storage Tools 1.3 for Red Hat Enterprise Linux 7 Server (RPMs)'
hammer repository-set enable --organization $ORG --product 'Oracle Java for RHEL Server' --basearch='x86_64' --releasever='7Server' --name 'Red Hat Enterprise Linux 7 Server - Oracle Java (RPMs)'
hammer repository-set enable --organization $ORG --product 'Red Hat Enterprise Linux Server' --basearch='x86_64' --name 'Red Hat Satellite Tools 6.4 (for RHEL 7 Server) (RPMs)'
wget -q https://dl.fedoraproject.org/pub/epel/RPM-GPG-KEY-EPEL-7 -O /root/RPM-GPG-KEY-EPEL-7
wget -q https://dl.fedoraproject.org/pub/epel/RPM-GPG-KEY-EPEL-7Server -O /root/RPM-GPG-KEY-EPEL-7Server
sleep 10
hammer gpg create --key /root/RPM-GPG-KEY-EPEL-7  --name 'GPG-EPEL-7' --organization $ORG
hammer gpg create --key /root/RPM-GPG-KEY-EPEL-7Server  --name 'GPG-EPEL-7Sever' --organization $ORG
sleep 10
hammer product create --name='Extra Packages for Enterprise Linux 7' --organization $ORG
hammer product create --name='Extra Packages for Enterprise Linux 7Server' --organization $ORG
sleep 10
hammer repository create --name='Extra Packages for Enterprise Linux 7' --organization $ORG --product='Extra Packages for Enterprise Linux 7' --content-type yum --publish-via-http=true --url=https://dl.fedoraproject.org/pub/epel/7/x86_64/
hammer repository create --name='Extra Packages for Enterprise Linux 7Server' --organization $ORG --product='Extra Packages for Enterprise Linux 7Server' --content-type yum --publish-via-http=true --url=https://dl.fedoraproject.org/pub/epel/7Server/x86_64/
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
function REQUESTRHSCL {
#-------------------------------
source /root/.bashrc
echo -ne "\e[8;40;170t"
echo "*********************************************************"
echo "RED HAT SOFTWARE COLLECTIONS RPMS FOR RED HAT ENTERPRISE LINUX 7 SERVER:"
echo "*********************************************************"
read -n1 -t$COUNTDOWN -p "$QMESSAGERHSCL ? Y/N " INPUT
INPUT=${INPUT:-$DEFAULTVALUE}
if  [ "$INPUT" = "y" -o "$INPUT" = "Y" ] ;then
echo -e "\n$YMESSAGE\n"
hammer repository-set enable --organization $ORG --product 'Red Hat Software Collections for RHEL Server' --basearch='x86_64' --releasever='7Server' --name 'Red Hat Software Collections RPMs for Red Hat Enterprise Linux 7 Server x86_64 7Server'
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
function REQUESTJBOSS {
#-------------------------------
source /root/.bashrc
echo -ne "\e[8;40;170t"
echo "*********************************************************"
echo "JBOSS ENTERPRISE APPLICATION PLATFORM 7:"
echo "*********************************************************"
read -n1 -t$COUNTDOWN -p "$QMESSAGEJBOSS ? Y/N " INPUT
INPUT=${INPUT:-$DEFAULTVALUE}
if  [ "$INPUT" = "y" -o "$INPUT" = "Y" ] ;then
echo -e "\n$YMESSAGE\n"
hammer repository-set enable --organization $ORG --product 'JBoss Enterprise Application Platform' --basearch='x86_64' --releasever='7Server' --name 'JBoss Enterprise Application Platform 7 (RHEL 7 Server) (RPMs)'
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
function REQUESTVIRTAGENT {
#-------------------------------
source /root/.bashrc
echo -ne "\e[8;40;170t"
echo "*********************************************************"
echo "RED HAT VIRTUALIZATION 4 MANAGEMENT AGENTS:"
echo "*********************************************************"
read -n1 -t$COUNTDOWN -p "$QMESSAGEVIRTAGENT ? Y/N " INPUT
INPUT=${INPUT:-$DEFAULTVALUE}
if  [ "$INPUT" = "y" -o "$INPUT" = "Y" ] ;then
echo -e "\n$YMESSAGE\n"
hammer repository-set enable --organization $ORG --product 'Red Hat Virtualization' --basearch='x86_64' --releasever='7Server' --name 'Red Hat Virtualization 4 Management Agents for RHEL 7 (RPMs)'
#COMMANDEXECUTION
elif [ "$INPUT" = "n" -o "$INPUT" = "N" ] ;then
echo -e "\n$NMESSAGE\n"
#COMMANDEXECUTIONICINGA
else
echo -e "\n$FMESSAGE\n"
REQUEST
fi
}
#-------------------------------
function REQUESTSAT64 {
#-------------------------------
source /root/.bashrc
echo -ne "\e[8;40;170t"
echo "*********************************************************"
echo "RED HAT SATELLITE 6.4:"
echo "*********************************************************"
read -n1 -t$COUNTDOWN -p "$QMESSAGESAT64 ? Y/N " INPUT
INPUT=${INPUT:-$DEFAULTVALUE}
if  [ "$INPUT" = "y" -o "$INPUT" = "Y" ] ;then
echo -e "\n$YMESSAGE\n"
hammer repository-set enable --organization $ORG --product 'Red Hat Satellite' --basearch='x86_64' --name 'Red Hat Satellite 6.4 (for RHEL 7 Server) (RPMs)'
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
function REQUESTOSC {
#-------------------------------
source /root/.bashrc
echo -ne "\e[8;40;170t"
echo "*********************************************************"
echo "RED HAT OPENSHIFT CONTAINER PLATFORM 3.10:"
echo "*********************************************************"
read -n1 -t$COUNTDOWN -p "$QMESSAGEOSC ? Y/N " INPUT
INPUT=${INPUT:-$DEFAULTVALUE}
if  [ "$INPUT" = "y" -o "$INPUT" = "Y" ] ;then
echo -e "\n$YMESSAGE\n"
hammer repository-set enable --organization $ORG --product 'Red Hat OpenShift Container Platform' --basearch='x86_64' --name 'Red Hat OpenShift Container Platform 3.10 (RPMs)'
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
function REQUESTCEPH {
#-------------------------------
source /root/.bashrc
echo -ne "\e[8;40;170t"
echo "*********************************************************"
echo "RED HAT CEPH:"
echo "*********************************************************"
read -n1 -t$COUNTDOWN -p "$QMESSAGECEPH ? Y/N " INPUT
INPUT=${INPUT:-$DEFAULTVALUE}
if  [ "$INPUT" = "y" -o "$INPUT" = "Y" ] ;then
echo -e "\n$YMESSAGE\n"
hammer repository-set enable --organization $ORG --product 'Red Hat Ceph Storage' --basearch='x86_64' --name 'Red Hat Ceph Storage 3 for Red Hat Enterprise Linux 7 Server (FILEs) '
hammer repository-set enable --organization $ORG --product 'Red Hat Enterprise Linux Server' --basearch='x86_64' --releasever='7Server' --name 'Red Hat Ceph Storage Tools 3 for Red Hat Enterprise Linux 7 Server (RPMs)'
hammer repository-set enable --organization $ORG --product 'Red Hat Ceph Storage MON' --basearch='x86_64' --releasever='7Server' --name 'Red Hat Ceph Storage MON 3 for Red Hat Enterprise Linux 7 Server (RPMs)'
hammer repository-set enable --organization $ORG --product 'Red Hat Ceph Storage MON' --basearch='x86_64' --releasever='7Server' --name 'Red Hat Ceph Storage 3 Text-Only Advisories for Red Hat Enterprise Linux 7 Server (RPMs)'
hammer repository-set enable --organization $ORG --product 'Red Hat Ceph Storage OSD ' --basearch='x86_64' --releasever='7Server' --name 'Red Hat Ceph Storage OSD 3 for Red Hat Enterprise Linux 7 Server (RPMs)'
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
function REQUESTSNC {
#-------------------------------
source /root/.bashrc
echo -ne "\e[8;40;170t"
echo "*********************************************************"
echo "RED HAT STORAGE NATIVE CLIENT:"
echo "*********************************************************"
read -n1 -t$COUNTDOWN -p "$QMESSAGESNC ? Y/N " INPUT
INPUT=${INPUT:-$DEFAULTVALUE}
if  [ "$INPUT" = "y" -o "$INPUT" = "Y" ] ;then
echo -e "\n$YMESSAGE\n"
hammer repository-set enable --organization $ORG --product 'Red Hat Enterprise Linux Server' --basearch='x86_64' --releasever='7Server' --name 'Red Hat Storage Native Client for RHEL 7 (RPMs)'
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
function REQUESTCSI {
#-------------------------------
source /root/.bashrc
echo -ne "\e[8;40;170t"
echo "*********************************************************"
echo "RED HAT CEPH STORAGE:"
echo "*********************************************************"
read -n1 -t$COUNTDOWN -p "$QMESSAGECSI ? Y/N " INPUT
INPUT=${INPUT:-$DEFAULTVALUE}
if  [ "$INPUT" = "y" -o "$INPUT" = "Y" ] ;then
echo -e "\n$YMESSAGE\n"
hammer repository-set enable --organization $ORG --product 'Red Hat Ceph Storage' --basearch='x86_64' --releasever='7Server' --name 'Red Hat Ceph Storage Installer 1.3 for Red Hat Enterprise Linux 7 Server (RPMs)'
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
function REQUESTOSP {
#-------------------------------
source /root/.bashrc
echo -ne "\e[8;40;170t"
echo "*********************************************************"
echo "OPENSTACK PLATFORM 13:"
echo "*********************************************************"
read -n1 -t$COUNTDOWN -p "$QMESSAGEOSP ? Y/N " INPUT
INPUT=${INPUT:-$DEFAULTVALUE}
if  [ "$INPUT" = "y" -o "$INPUT" = "Y" ] ;then
echo -e "\n$YMESSAGE\n"
hammer repository-set enable --organization $ORG --product 'Red Hat OpenStack' --basearch='x86_64' --releasever='7Server' --name 'Red Hat OpenStack Platform 13 for RHEL 7 (RPMs)'
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
function REQUESTOSPT {
#-------------------------------
source /root/.bashrc
echo -ne "\e[8;40;170t"
echo "*********************************************************"
echo "OPENSTACK PLATFORM 13 OPERATIONAL TOOLS:"
echo "*********************************************************"
read -n1 -t$COUNTDOWN -p "$QMESSAGEOSPT ? Y/N " INPUT
NPUT=${INPUT:-$DEFAULTVALUE}
if  [ "$INPUT" = "y" -o "$INPUT" = "Y" ] ;then
echo -e "\n$YMESSAGE\n"
hammer repository-set enable --organization $ORG --product 'Red Hat OpenStack' --basearch='x86_64' --releasever='7Server' --name 'Red Hat OpenStack Platform 13 Operational Tools for RHEL 7 (RPMs)'
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
function REQUESTOSPD {
#-------------------------------
source /root/.bashrc
echo -ne "\e[8;40;170t"
echo "*********************************************************"
echo "OPENSTACK PLATFORM 13 DIRECTOR:"
echo "*********************************************************"
read -n1 -t$COUNTDOWN -p "$QMESSAGEOSPD ? Y/N " INPUT
INPUT=${INPUT:-$DEFAULTVALUE}
if  [ "$INPUT" = "y" -o "$INPUT" = "Y" ] ;then
echo -e "\n$YMESSAGE\n"
hammer repository-set enable --organization $ORG --product 'Red Hat OpenStack' --basearch='x86_64' --releasever='7Server' --name 'Red Hat OpenStack Platform 13 director for RHEL 7 (RPMs)'
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
function REQUESTRHVH {
#-------------------------------
source /root/.bashrc
echo -ne "\e[8;40;170t"
echo "*********************************************************"
echo "RHVH:"
echo "*********************************************************"
read -n1 -t$COUNTDOWN -p "$QMESSAGERHVH ? Y/N " INPUT
INPUT=${INPUT:-$DEFAULTVALUE}
if  [ "$INPUT" = "y" -o "$INPUT" = "Y" ] ;then
echo -e "\n$YMESSAGE\n"
hammer repository-set enable --organization $ORG --product 'Red Hat Virtualization Host' --basearch='x86_64' --name 'Red Hat Virtualization Host 7 (RPMs)'
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
function REQUESTRHVM {
#-------------------------------
source /root/.bashrc
echo -ne "\e[8;40;170t"
echo "*********************************************************"
echo "RHV:"
echo "*********************************************************"
read -n1 -t$COUNTDOWN -p "$QMESSAGERHVM ? Y/N " INPUT
INPUT=${INPUT:-$DEFAULTVALUE}
if  [ "$INPUT" = "y" -o "$INPUT" = "Y" ] ;then
echo -e "\n$YMESSAGE\n"
hammer repository-set enable --organization $ORG --product 'Red Hat Virtualization' --basearch='x86_64' --name 'Red Hat Virtualization Manager 4.2 (RHEL 7 Server) (RPMs)'
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
function REQUESTATOMIC {
#-------------------------------
source /root/.bashrc
echo -ne "\e[8;40;170t"
echo "*********************************************************"
echo "ATOMIC:"
echo "*********************************************************"
read -n1 -t$COUNTDOWN -p "$QMESSAGEATOMIC ? Y/N " INPUT
INPUT=${INPUT:-$DEFAULTVALUE}
if  [ "$INPUT" = "y" -o "$INPUT" = "Y" ] ;then
echo -e "\n$YMESSAGE\n"
hammer repository-set enable --organization $ORG --product 'Red Hat Enterprise Linux Atomic Host' --basearch='x86_64' --name 'Red Hat Enterprise Linux Atomic Host (RPMs)'
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
function REQUESTTOWER {
#-------------------------------
source /root/.bashrc
echo -ne "\e[8;40;170t"
echo "*********************************************************"
echo "ANSIBLE TOWER:"
echo "*********************************************************"
read -n1 -t$COUNTDOWN -p "$QMESSAGETOWER ? Y/N " INPUT
INPUT=${INPUT:-$DEFAULTVALUE}
if  [ "$INPUT" = "y" -o "$INPUT" = "Y" ] ;then
echo -e "\n$YMESSAGE\n"
hammer product create --name='Ansible-Tower' --organization $ORG
hammer repository create --name='Ansible-Tower' --organization $ORG --product='Ansible-Tower' --content-type yum --publish-via-http=true --url=http://releases.ansible.com/ansible-tower/rpm/epel-7-x86_64/ 
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
function REQUESTPUPPET {
#-------------------------------
source /root/.bashrc
echo -ne "\e[8;40;170t"
echo "*********************************************************"
echo "PUPPET FORGE:"
echo "*********************************************************"
read -n1 -t$COUNTDOWN -p "$QMESSAGEPUPPET ? Y/N " INPUT
INPUT=${INPUT:-$DEFAULTVALUE}
if  [ "$INPUT" = "y" -o "$INPUT" = "Y" ] ;then
echo -e "\n$YMESSAGE\n"
hammer product create --name='Puppet Forge' --organization $ORG
hammer repository create --name='Puppet Forge' --organization $ORG --product='Puppet Forge' --content-type puppet --publish-via-http=true --url=https://forge.puppetlabs.com 
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
function REQUESTJENKINS {
#-------------------------------
source /root/.bashrc
echo -ne "\e[8;40;170t"
echo "*********************************************************"
echo "JENKINS:"
echo "*********************************************************"
read -n1 -t$COUNTDOWN -p "$QMESSAGEJENKINS ? Y/N " INPUT
INPUT=${INPUT:-$DEFAULTVALUE}
if  [ "$INPUT" = "y" -o "$INPUT" = "Y" ] ;then
echo -e "\n$YMESSAGE\n"
wget http://pkg.jenkins.io/redhat-stable/jenkins.io.key
hammer gpg create --organization $ORG --name GPG-JENKINS --key jenkins.io.key
hammer product create --name='JENKINS' --organization $ORG
hammer repository create  --organization $ORG --name='JENKINS' --product=$ORG --gpg-key='GPG-JENKINS' --content-type='yum' --publish-via-http=true --url=https://pkg.jenkins.io/redhat/ --download-policy immediate
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
function REQUESTMAVEN {
#-------------------------------
source /root/.bashrc
echo -ne "\e[8;40;170t"
echo "*********************************************************"
echo "MAVEN:"
echo "*********************************************************"
read -n1 -t$COUNTDOWN -p "$QMESSAGEMAVEN ? Y/N " INPUT
INPUT=${INPUT:-$DEFAULTVALUE}
if  [ "$INPUT" = "y" -o "$INPUT" = "Y" ] ;then
echo -e "\n$YMESSAGE\n"
hammer product create --name='Maven' --organization $ORG
hammer repository create  --organization $ORG --name='Maven 7Server' --product='Maven' --content-type='yum' --publish-via-http=true --url=https://repos.fedorapeople.org/repos/dchen/apache-maven/epel-7Server/x86_64/ --download-policy immediate
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
function REQUESTICINGA {
#-------------------------------
source /root/.bashrc
echo -ne "\e[8;40;170t"
echo "*********************************************************"
echo "ICINGA:"
echo "*********************************************************"
read -n1 -t$COUNTDOWN -p "$QMESSAGEICINGA ? Y/N " INPUT
INPUT=${INPUT:-$DEFAULTVALUE}
if  [ "$INPUT" = "y" -o "$INPUT" = "Y" ] ;then
echo -e "\n$YMESSAGE\n"
wget http://packages.icinga.org/icinga.key
hammer gpg create --organization $ORG --name GPG-ICINGA --key icinga.key
hammer product create --name='Icinga' --organization $ORG
hammer repository create  --organization $ORG --name='Icinga 7Server' --product='Icinga' --content-type='yum' --gpg-key='GPG-ICINGA' --publish-via-http=true --url=http://packages.icinga.org/epel/7Server/release --download-policy immediate
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
function REQUESTCENTOS7 {
#-------------------------------
source /root/.bashrc
echo -ne "\e[8;40;170t"
echo "*********************************************************"
echo "CentOS-7:"
echo "*********************************************************"
read -n1 -t$COUNTDOWN -p "$QMESSAGEICENTOS7 ? Y/N " INPUT
INPUT=${INPUT:-$DEFAULTVALUE}
if  [ "$INPUT" = "y" -o "$INPUT" = "Y" ] ;then
echo -e "\n$YMESSAGE\n"
cd /root/Downloads
wget http://mirror.centos.org/centos/RPM-GPG-KEY-CentOS-7
hammer gpg create --organization $ORG --name RPM-GPG-KEY-CentOS-7 --key RPM-GPG-KEY-CentOS-7
hammer product create --name='CentOS-7' --organization $ORG
hammer repository create  --organization $ORG --name='CentOS-7 (Kickstart)' --product='CentOS-7' --content-type='yum' --gpg-key='RPM-GPG-KEY-CentOS-7' --publish-via-http=true --url=http://mirror.centos.org/centos/7.6.1810/os/x86_64/ --download-policy immediate --checksum-type=sha256
hammer repository create  --organization $ORG --name='CentOS-7 CentOSplus' --product='CentOS-7' --content-type='yum' --gpg-key='RPM-GPG-KEY-CentOS-7' --publish-via-http=true --url=http://mirror.centos.org/centos/7.6.1810/centosplus/x86_64/ --checksum-type=sha256
hammer repository create  --organization $ORG --name='CentOS-7 DotNET' --product='CentOS-7' --content-type='yum' --gpg-key='RPM-GPG-KEY-CentOS-7' --publish-via-http=true --url=http://mirror.centos.org/centos/7.6.1810/dotnet/x86_64/ --checksum-type=sha256
hammer repository create  --organization $ORG --name='CentOS-7 Extras' --product='CentOS-7' --content-type='yum' --gpg-key='RPM-GPG-KEY-CentOS-7' --publish-via-http=true --url=http://mirror.centos.org/centos/7.6.1810/extras/x86_64/ --checksum-type=sha256
hammer repository create  --organization $ORG --name='CentOS-7 Fasttrack' --product='CentOS-7' --content-type='yum' --gpg-key='RPM-GPG-KEY-CentOS-7' --publish-via-http=true --url=http://mirror.centos.org/centos/7.6.1810/fasttrack/x86_64/ --checksum-type=sha256
hammer repository create  --organization $ORG --name='CentOS-7 ISO' --product='CentOS-7' --content-type='yum' --gpg-key='RPM-GPG-KEY-CentOS-7' --publish-via-http=true --url=http://centos.host-engine.com/7.6.1810/isos/x86_64/CentOS-7-x86_64-DVD-1810.iso --checksum-type=sha256
hammer repository create  --organization $ORG --name='CentOS-7 Openshift-Origin' --product='CentOS-7' --content-type='yum' --gpg-key='RPM-GPG-KEY-CentOS-7' --publish-via-http=true --url=http://mirror.centos.org/centos/7.6.1810/paas/x86_64/openshift-origin/ --checksum-type=sha256
hammer repository create  --organization $ORG --name='CentOS-7 OpsTools' --product='CentOS-7' --content-type='yum' --gpg-key='RPM-GPG-KEY-CentOS-7' --publish-via-http=true --url=http://mirror.centos.org/centos/7.6.1810/opstools/x86_64/ --checksum-type=sha256
hammer repository create  --organization $ORG --name='CentOS-7 Gluster 5' --product='CentOS-7' --content-type='yum' --gpg-key='RPM-GPG-KEY-CentOS-7' --publish-via-http=true --url=http://mirror.centos.org/centos/7.6.1810/storage/x86_64/gluster-5/ --checksum-type=sha256
hammer repository create  --organization $ORG --name='CentOS-7 Ceph-Luminous' --product='CentOS-7' --content-type='yum' --gpg-key='RPM-GPG-KEY-CentOS-7' --publish-via-http=true --url=http://mirror.centos.org/centos/7.6.1810/storage/x86_64/ceph-luminous/ --checksum-type=sha256
hammer repository create  --organization $ORG --name='CentOS-7 Updates' --product='CentOS-7' --content-type='yum' --gpg-key='RPM-GPG-KEY-CentOS-7' --publish-via-http=true --url=http://mirror.centos.org/centos/7.6.1810/updates/x86_64/ --checksum-type=sha256
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
function SYNC {
#------------------------------
source /root/.bashrc
echo -ne "\e[8;40;170t"
echo "*********************************************************"
echo "SYNC ALL REPOSITORIES (WAIT FOR THIS TO COMPLETE BEFORE CONTINUING):"
echo "*********************************************************"
for i in $(hammer --csv repository list --organization $ORG | awk -F, {'print $1'} | grep -vi '^ID'); do hammer repository synchronize --id ${i} --organization $ORG --async; done
firefox https://127.0.0.1/katello/sync_management -y &
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
function ENVIRONMENTS {
#-------------------------------
source /root/.bashrc
echo -ne "\e[8;40;170t"
echo " "
echo "*********************************************************"
echo "CREATE ENVIRONMENTS DEV_RHEL->TEST_RHEL->PROD_RHEL:"
echo "*********************************************************"
echo "DEVLOPMENT_RHEL_7"
hammer lifecycle-environment create --name='DEV_RHEL_7' --prior='Library' --organization $ORG
echo "TEST_RHEL_7"
hammer lifecycle-environment create --name='TEST_RHEL_7' --prior='DEV_RHEL_7' --organization $ORG
echo "PRODUCTION_RHEL_7"
hammer lifecycle-environment create --name='PROD_RHEL_7' --prior='TEST_RHEL_7' --organization $ORG
echo "DEVLOPMENT_RHEL_6"
hammer lifecycle-environment create --name='DEV_RHEL_6' --prior='Library' --organization $ORG
echo "TEST_RHEL_6"
hammer lifecycle-environment create --name='TEST_RHEL_6' --prior='DEV_RHEL_6' --organization $ORG
echo "PRODUCTION_RHEL_6"
hammer lifecycle-environment create --name='PROD_RHEL_6' --prior='TEST_RHEL_6' --organization $ORG
echo "DEVLOPMENT_RHEL_5"
hammer lifecycle-environment create --name='DEV_RHEL_5' --prior='Library' --organization $ORG
echo "TEST_RHEL_5"
hammer lifecycle-environment create --name='TEST_RHEL_5' --prior='DEV_RHEL_5' --organization $ORG
echo "PRODUCTION_RHEL_5"
hammer lifecycle-environment create --name='PROD_RHEL_5' --prior='TEST_RHEL_5' --organization $ORG
echo "DEVLOPMENT_CentOS_7"
hammer lifecycle-environment create --name='DEV_CentOS_7' --prior='Library' --organization $ORG
echo "TEST_CentOS_7"
hammer lifecycle-environment create --name='TEST_CentOS_7' --prior='DEV_CentOS_7' --organization $ORG
echo "PRODUCTION_CentOS_7"
hammer lifecycle-environment create --name='PROD_CentOS_7' --prior='TEST_CentOS_7' --organization $ORG
echo " "
hammer lifecycle-environment list --organization $ORG
}
#-------------------------------
function DAILYSYNC {
#-------------------------------
source /root/.bashrc
echo -ne "\e[8;40;170t"
echo " "
echo "*********************************************************"
echo "Create a daily sync plan:"
echo "*********************************************************"
hammer sync-plan create --name 'Daily_Sync' --description 'Daily Synchronization Plan' --organization $ORG --interval daily --sync-date $(date +"%Y-%m-%d")" 00:00:00" --enabled no
hammer sync-plan create --name 'Weekly_Sync' --description 'Weekly Synchronization Plan' --organization $ORG --interval weekly --sync-date $(date +"%Y-%m-%d")" 00:00:00" --enabled yes
hammer sync-plan list --organization $ORG
}
#-------------------------------
function SYNCPLANCOMPONENTS {
#-------------------------------
source /root/.bashrc
echo -ne "\e[8;40;170t"
echo " "
hammer product set-sync-plan --name 'Red Hat Enterprise Linux Server' --organization $ORG --sync-plan 'Weekly_Sync'
hammer product set-sync-plan --name 'Extra Packages for Enterprise Linux 7' --organization $ORG --sync-plan 'Weekly_Sync'
hammer product set-sync-plan --name 'Extra Packages for Enterprise Linux 6' --organization $ORG --sync-plan 'Weekly_Sync'
hammer product set-sync-plan --name 'Extra Packages for Enterprise Linux 5' --organization $ORG --sync-plan 'Weekly_Sync'
hammer product set-sync-plan --name 'Puppet Forge' --organization $ORG --sync-plan 'Weekly_Sync'
hammer product set-sync-plan --name 'CentOS-7' --organization $ORG --sync-plan 'Weekly_Sync'
}
#-------------------------------
function ASSOCPLANTOPRODUCTS {
#-------------------------------
source /root/.bashrc
echo -ne "\e[8;40;170t"
echo " "
echo "*********************************************************"
echo "Associate plan to products:"
echo "*********************************************************"
hammer product set-sync-plan --sync-plan-id=1 --organization $ORG --name='Oracle Java for RHEL Server'
hammer product set-sync-plan --sync-plan-id=1 --organization $ORG --name='Red Hat Enterprise Linux Server'
hammer product set-sync-plan --sync-plan-id=1 --organization $ORG --name='Puppet Forge'
hammer product set-sync-plan --sync-plan-id=2 --organization $ORG --name='Extra Packages for Enterprise Linux 5'
hammer product set-sync-plan --sync-plan-id=2 --organization $ORG --name='Extra Packages for Enterprise Linux 6'
hammer product set-sync-plan --sync-plan-id=1 --organization $ORG --name='Extra Packages for Enterprise Linux 7'
hammer product set-sync-plan --sync-plan-id=2 --organization $ORG --name='CentOS-7'
}
#-------------------------------
function CONTENTVIEWS {
#-------------------------------
source /root/.bashrc
echo -ne "\e[8;40;170t"
echo " "
echo "***********************************************"
echo "Create a content view for CentOS-7:"
echo "***********************************************"
#hammer content-view create --name='RHEL7-server-x86_64' --organization $ORG
#sleep 20
#for i in $(hammer --csv repository list --organization $ORG | awk -F, {'print $1'} | grep -vi '^ID'); do hammer content-view add-repository --name RHEL7-Base --organization $ORG --repository-id=${i}; done  
hammer content-view create --organization $ORG --name 'CentOS 7' --label 'CentOS7' --description 'CentOS 7'
hammer content-view add-repository --organization $ORG --name 'CentOS 7' --product 'CentOS-7' --repository 'CentOS-7 (Kickstart)'
hammer content-view add-repository --organization $ORG --name 'CentOS 7' --product 'CentOS-7' --repository 'CentOS-7 Gluster 5'
hammer content-view add-repository --organization $ORG --name 'CentOS 7' --product 'CentOS-7' --repository 'CentOS-7 Extras'
hammer content-view add-repository --organization $ORG --name 'CentOS 7' --product 'CentOS-7' --repository 'CentOS-7 ISO'
hammer content-view add-repository --organization $ORG --name 'CentOS 7' --product 'CentOS-7' --repository 'CentOS-7 Openshift-Origin'
hammer content-view add-repository --organization $ORG --name 'CentOS 7' --product 'CentOS-7' --repository 'CentOS-7 DotNET'
hammer content-view add-repository --organization $ORG --name 'CentOS 7' --product 'CentOS-7' --repository 'CentOS-7 CentOSplus'
hammer content-view add-repository --organization $ORG --name 'CentOS 7' --product 'CentOS-7' --repository 'CentOS-7 Ceph-Luminous'
hammer content-view add-repository --organization $ORG --name 'CentOS 7' --product 'CentOS-7' --repository 'CentOS-7 Fasttrack'
hammer content-view add-repository --organization $ORG --name 'CentOS 7' --product 'CentOS-7' --repository 'CentOS-7 OpsTools'
hammer content-view add-repository --organization $ORG --name 'CentOS 7' --product 'CentOS-7' --repository 'CentOS-7 Updates'
time hammer content-view publish --organization $ORG --name 'CentOS 7' --description 'Initial Publishing' 2>/dev/null
time hammer content-view version promote --organization $ORG --content-view 'CentOS 7' --to-lifecycle-environment DEV_CentOS_7  2>/dev/null
echo "***********************************************"
echo "CREATE A CONTENT VIEW FOR RHEL 7:"
echo "***********************************************"
hammer content-view create --organization $ORG --name 'RHEL 7' --label RHEL7 --description 'RHEL 7'
hammer content-view add-repository --organization $ORG --name 'RHEL 7' --product 'Red Hat Enterprise Linux Server' --repository 'Red Hat Enterprise Linux 7 Server RPMs x86_64 7Server'
hammer content-view add-repository --organization $ORG --name 'RHEL 7' --product 'Red Hat Enterprise Linux Server' --repository 'Red Hat Enterprise Linux 7 Server Kickstart x86_64 7.6'
hammer content-view add-repository --organization $ORG --name 'RHEL 7' --product 'Red Hat Enterprise Linux Server' --repository 'Red Hat Satellite Tools 6.4 for RHEL 7 Server RPMs x86_64'
hammer content-view puppet-module add --organization $ORG --content-view 'RHEL 7' --author puppetlabs --name stdlib
hammer content-view puppet-module add --organization $ORG --content-view 'RHEL 7' --author puppetlabs --name concat
hammer content-view puppet-module add --organization $ORG --content-view 'RHEL 7' --author puppetlabs --name ntp
hammer content-view puppet-module add --organization $ORG --content-view 'RHEL 7' --author saz --name ssh
time hammer content-view publish --organization $ORG --name 'RHEL 7' --description 'Initial Publishing' 2>/dev/null
time hammer content-view version promote --organization $ORG --content-view 'RHEL 7' --to-lifecycle-environment DEV_RHEL_7  2>/dev/null
echo "***********************************************"
echo "CREATE A CONTENT VIEW FOR RHEL 7 CAPSULES:"
echo "***********************************************"
hammer content-view create --organization $ORG --name 'RHEL7-Capsule' --label 'RHEL7-Capsule' --description 'Satellite Capsule'
hammer content-view add-repository --organization $ORG --name 'RHEL7-Capsule' --product 'Red Hat Enterprise Linux Server' --repository 'Red Hat Enterprise Linux 7 Server RPMs x86_64 7Server'
hammer content-view add-repository --organization $ORG --name 'RHEL7-Capsule' --product 'Red Hat Enterprise Linux Server' --repository 'Red Hat Enterprise Linux 7 Server Kickstart x86_64 7.6'
hammer content-view add-repository --organization $ORG --name 'RHEL7-Capsule' --product 'Red Hat Enterprise Linux Server' --repository 'Red Hat Satellite Tools 6.4 for RHEL 7 Server RPMs x86_64'
hammer content-view add-repository --organization $ORG --name 'RHEL7-Capsule' --product 'Red Hat Enterprise Linux Server' --repository 'Red Hat Enterprise Linux 7 Server - Optional RPMs x86_64 7Server'
hammer content-view add-repository --organization $ORG --name 'RHEL7-Capsule' --product 'Red Hat Software Collections for RHEL Server' --repository 'Red Hat Software Collections RPMs for Red Hat Enterprise Linux 7 Server x86_64 7Server'
hammer content-view add-repository --organization $ORG --name 'RHEL7-Capsule' --product 'Red Hat Satellite Capsule' --repository 'Red Hat Satellite Capsule 6.4 for RHEL 7 Server RPMs x86_64'
hammer content-view add-repository --organization $ORG --name 'RHEL7-Capsule' --product 'Red Hat Satellite Capsule' --repository 'Red Hat Satellite Capsule 6.4 - Puppet 4 for RHEL 7 Server RPMs x86_64'
hammer content-view puppet-module add --organization $ORG --content-view 'RHEL7-Capsule' --author puppetlabs --name stdlib
hammer content-view puppet-module add --organization $ORG --content-view 'RHEL7-Capsule' --author puppetlabs --name concat
hammer content-view puppet-module add --organization $ORG --content-view 'RHEL7-Capsule' --author puppetlabs --name ntp
hammer content-view puppet-module add --organization $ORG --content-view 'RHEL7-Capsule' --author saz --name ssh
time hammer content-view publish --organization $ORG --name 'RHEL7-Capsule' --description 'Initial Publishing' 2>/dev/null
time hammer content-view version promote --organization $ORG --content-view 'RHEL7-Capsule' --to-lifecycle-environment DEV_RHEL_7  2>/dev/null
echo "***********************************************"
echo "CREATE A CONTENT VIEW FOR RHEL 7 Hypervisor:"
echo "***********************************************"
hammer content-view create --organization $ORG --name 'RHEL7-Hypervisor' --label 'RHEL7-Hypervisor' --description ''
hammer content-view add-repository --organization $ORG --name 'RHEL7-Hypervisor' --product 'Red Hat Enterprise Linux Server' --repository 'Red Hat Enterprise Linux 7 Server RPMs x86_64 7Server'
hammer content-view add-repository --organization $ORG --name 'RHEL7-Hypervisor' --product 'Red Hat Enterprise Linux Server' --repository 'Red Hat Satellite Tools 6.4 for RHEL 7 Server RPMs x86_64'
#hammer content-view add-repository --organization $ORG --name 'RHEL7-Hypervisor' --product 'Red Hat Enterprise Linux Server' --repository 'Red Hat Satellite Tools 6.4 - Puppet 4 for RHEL 7 Server RPMs x86_64'
hammer content-view add-repository --organization $ORG --name 'RHEL7-Hypervisor' --product 'Red Hat Virtualization' --repository 'Red Hat Virtualization 4 Management Agents for RHEL 7 RPMs x86_64 7Server'
hammer content-view puppet-module add --organization $ORG --content-view 'RHEL7-Hypervisor' --author puppetlabs --name stdlib
hammer content-view puppet-module add --organization $ORG --content-view 'RHEL7-Hypervisor' --author puppetlabs --name concat
hammer content-view puppet-module add --organization $ORG --content-view 'RHEL7-Hypervisor' --author puppetlabs --name ntp
time hammer content-view publish --organization $ORG --name 'RHEL7-Hypervisor' --description 'Initial Publishing' 2>/dev/null
time hammer content-view version promote --organization $ORG --content-view 'RHEL7-Hypervisor' --to-lifecycle-environment DEV_RHEL_7  2>/dev/null
echo "***********************************************"
echo "CREATE A CONTENT VIEW FOR RHEL 7 Builder:"
echo "***********************************************"
hammer content-view create --organization $ORG --name 'RHEL7-Builder' --label RHEL7-Builder --description 'RHEL7-Builder'
hammer content-view add-repository --organization $ORG --name 'RHEL7-Builder' --product 'Red Hat Enterprise Linux Server' --repository 'Red Hat Enterprise Linux 7 Server RPMs x86_64 7Server'
hammer content-view add-repository --organization $ORG --name 'RHEL7-Builder' --product 'Red Hat Enterprise Linux Server' --repository 'Red Hat Enterprise Linux 7 Server Kickstart x86_64 7.6'
hammer content-view add-repository --organization $ORG --name 'RHEL7-Builder' --product 'Red Hat Enterprise Linux Server' --repository 'Red Hat Satellite Tools 6.4 for RHEL 7 Server RPMs x86_64'
hammer content-view add-repository --organization $ORG --name 'RHEL7-Builder' --product 'Red Hat Software Collections for RHEL Server' --repository 'Red Hat Software Collections RPMs for Red Hat Enterprise Linux 7 Server x86_64 7Server'
hammer content-view add-repository --organization $ORG --name 'RHEL7-Builder' --product 'Red Hat Enterprise Linux Server' --repository 'Red Hat Enterprise Linux 7 Server - Supplementary RPMs x86_64 7Server'
hammer content-view add-repository --organization $ORG --name 'RHEL7-Builder' --product 'Red Hat Enterprise Linux Server' --repository 'Red Hat Enterprise Linux 7 Server - RH Common RPMs x86_64 7Server'
hammer content-view add-repository --organization $ORG --name 'RHEL7-Builder' --product 'Red Hat Enterprise Linux Server' --repository 'Red Hat Enterprise Linux 7 Server - Optional RPMs x86_64 7Server'
hammer content-view add-repository --organization $ORG --name 'RHEL7-Builder' --product 'Red Hat Enterprise Linux Server' --repository 'Red Hat Enterprise Linux 7 Server - Extras RPMs x86_64'
hammer content-view add-repository --organization $ORG --name 'RHEL7-Builder' --product 'JBoss Enterprise Application Platform' --repository 'JBoss Enterprise Application Platform 7 RHEL 7 Server RPMs x86_64 7Server'
hammer content-view add-repository --organization $ORG --name 'RHEL7-Builder' --product 'Maven' --repository 'Maven 7Server'
hammer content-view add-repository --organization $ORG --name 'RHEL7-Builder' --product 'EPEL' --repository 'EPEL 7 - x86_64'
hammer content-view add-repository --organization $ORG --name 'RHEL7-Builder' --product $ORG --repository "Packages"
hammer content-view add-repository --organization $ORG --name 'RHEL7-Builder' --product $ORG --repository "Jenkins"
hammer content-view puppet-module add --organization $ORG --content-view 'RHEL7-Builder' --author puppetlabs --name stdlib
hammer content-view puppet-module add --organization $ORG --content-view 'RHEL7-Builder' --author puppetlabs --name concat
hammer content-view puppet-module add --organization $ORG --content-view 'RHEL7-Builder' --author puppetlabs --name ntp
hammer content-view puppet-module add --organization $ORG --content-view 'RHEL7-Builder' --author saz --name ssh
hammer content-view puppet-module add --organization $ORG --content-view 'RHEL7-Builder' --author puppetlabs --name postgresql
hammer content-view puppet-module add --organization $ORG --content-view 'RHEL7-Builder' --author puppetlabs --name java
hammer content-view puppet-module add --organization $ORG --content-view 'RHEL7-Builder' --author rtyler --name jenkins
hammer content-view puppet-module add --organization $ORG --content-view 'RHEL7-Builder' --author camptocamp --name archive
time hammer content-view publish --organization $ORG --name 'RHEL7-Builder' --description 'Initial Publishing'
time hammer content-view version promote --organization $ORG --content-view 'RHEL7-Builder' --to-lifecycle-environment DEV_RHEL_7
echo "***********************************************"
echo "CREATE A CONTENT VIEW FOR RHEL 7 OSCP:"
echo "***********************************************"
hammer content-view create --organization $ORG --name 'RHEL7-Oscp' --label 'RHEL7-Oscp' --description ''
hammer content-view add-repository --organization $ORG --name 'RHEL7-Oscp' --product 'Red Hat Enterprise Linux Server' --repository 'Red Hat Enterprise Linux 7 Server RPMs x86_64 7Server'
hammer content-view add-repository --organization $ORG --name 'RHEL7-Oscp' --product 'Red Hat Enterprise Linux Server' --repository 'Red Hat Satellite Tools 6.4 for RHEL 7 Server RPMs x86_64'
hammer content-view add-repository --organization $ORG --name 'RHEL7-Oscp' --product 'Red Hat Software Collections for RHEL Server' --repository 'Red Hat Software Collections RPMs for Red Hat Enterprise Linux 7 Server x86_64 7Server'
hammer content-view add-repository --organization $ORG --name 'RHEL7-Oscp' --product 'Red Hat Enterprise Linux Server' --repository 'Red Hat Enterprise Linux 7 Server - Optional RPMs x86_64 7Server'
hammer content-view add-repository --organization $ORG --name 'RHEL7-Oscp' --product 'Red Hat Enterprise Linux Server' --repository 'Red Hat Enterprise Linux 7 Server - Extras RPMs x86_64'
hammer content-view add-repository --organization $ORG --name 'RHEL7-Oscp' --product 'Red Hat OpenShift Container Platform' --repository 'Red Hat OpenShift Container Platform 3.9 RPMs x86_64'
hammer content-view puppet-module add --organization $ORG --content-view 'RHEL7-Oscp' --author puppetlabs --name stdlib
hammer content-view puppet-module add --organization $ORG --content-view 'RHEL7-Oscp' --author puppetlabs --name concat
hammer content-view puppet-module add --organization $ORG --conten30t-view 'RHEL7-Oscp' --author puppetlabs --name ntp
hammer content-view puppet-module add --organization $ORG --content-view 'RHEL7-Oscp' --author saz --name ssh
hammer content-view puppet-module add --organization $ORG --content-view 'RHEL7-Oscp' --author cristifalcas --name kubernetes
hammer content-view puppet-module add --organization $ORG --content-view 'RHEL7-Oscp' --author cristifalcas --name etcd
hammer content-view puppet-module add --organization $ORG --content-view 'RHEL7-Oscp' --author LunetIX --name docker
hammer content-view puppet-module add --organization $ORG --content-view 'RHEL7-Oscp' --author crayfishx --name firewalld
time hammer content-view publish --organization $ORG --name 'RHEL7-Oscp' --description 'Initial Publishing'
time hammer content-view version promote --organization $ORG --content-view 'RHEL7-Oscp' --to-lifecycle-environment DEV_RHEL_7
echo "***********************************************"
echo "CREATE A CONTENT VIEW FOR RHEL 7 DOCKER:"
echo "***********************************************"
hammer content-view create --organization $ORG --name 'RHEL7-Docker' --label 'RHEL7-Docker' --description ''
hammer content-view add-repository --organization $ORG --name 'RHEL7-Docker' --product 'Red Hat Enterprise Linux Server' --repository 'Red Hat Enterprise Linux 7 Server RPMs x86_64 7Server'
hammer content-view add-repository --organization $ORG --name 'RHEL7-Docker' --product 'Red Hat Enterprise Linux Server' --repository 'Red Hat Satellite Tools 6.4 for RHEL 7 Server RPMs x86_64'
hammer content-view add-repository --organization $ORG --name 'RHEL7-Docker' --product 'Red Hat Software Collections for RHEL Server' --repository 'Red Hat Software Collections RPMs for Red Hat Enterprise Linux 7 Server x86_64 7Server'
hammer content-view add-repository --organization $ORG --name 'RHEL7-Docker' --product 'Red Hat Enterprise Linux Server' --repository 'Red Hat Enterprise Linux 7 Server - Optional RPMs x86_64 7Server'
hammer content-view add-repository --organization $ORG --name 'RHEL7-Docker' --product 'Red Hat Enterprise Linux Server' --repository 'Red Hat Enterprise Linux 7 Server - Extras RPMs x86_64'
hammer content-view add-repository --organization $ORG --name 'RHEL7-Docker' --product 'Red Hat OpenShift Container Platform' --repository 'Red Hat OpenShift Container Platform 3.9 RPMs x86_64'
hammer content-view add-repository --organization $ORG --name 'RHEL7-Docker' --product 'JBoss Enterprise Application Platform' --repository 'JBoss Enterprise Application Platform 7 RHEL 7 Server RPMs x86_64 7Server'
hammer content-view puppet-module add --organization $ORG --content-view 'RHEL7-Docker' --author puppetlabs --name stdlib
hammer content-view puppet-module add --organization $ORG --content-view 'RHEL7-Docker' --author puppetlabs --name concat
hammer content-view puppet-module add --organization $ORG --content-view 'RHEL7-Docker' --author puppetlabs --name ntp
hammer content-view puppet-module add --organization $ORG --content-view 'RHEL7-Docker' --author saz --name ssh
hammer content-view puppet-module add --organization $ORG --content-view 'RHEL7-Docker' --author cristifalcas --name kubernetes
hammer content-view puppet-module add --organization $ORG --content-view 'RHEL7-Docker' --author cristifalcas --name etcd
hammer content-view puppet-module add --organization $ORG --content-view 'RHEL7-Docker' --author cristifalcas --name docker
hammer content-view puppet-module add --organization $ORG --content-view 'RHEL7-Docker' --author crayfishx --name firewalld
hammer content-view puppet-module add --organization $ORG --content-view 'RHEL7-Docker' --author LunetIX --name dockerhost
time hammer content-view publish --organization $ORG --name 'RHEL7-Docker' --description 'Initial Publishing'
time hammer content-view version promote --organization $ORG --content-view 'RHEL7-Docker' --to-lifecycle-environment DEV_RHEL_7
echo '#-------------------------------'
echo 'RHEL6 CONTENT VIEW'
echo '#-------------------------------'
hammer content-view create --organization $ORG --name 'RHEL6_Base' --label 'RHEL6_Base' --description 'Core Build for RHEL 6'
hammer content-view add-repository --organization $ORG --name 'RHEL6_Base' --product 'Red Hat Enterprise Linux Server' --repository 'Red Hat Enterprise Linux 6 Server RPMs x86_64 6Server'
hammer content-view add-repository --organization $ORG --name 'RHEL6_Base' --product 'Red Hat Enterprise Linux Server' --repository 'Red Hat Satellite Tools 6.4 for RHEL 6 Server RPMs x86_64'
hammer content-view puppet-module add --organization $ORG --content-view 'RHEL6_Base' --author puppetlabs --name stdlib
hammer content-view puppet-module add --organization $ORG --content-view 'RHEL6_Base' --author puppetlabs --name concat
hammer content-view puppet-module add --organization $ORG --content-view 'RHEL6_Base' --author puppetlabs --name ntp
hammer content-view puppet-module add --organization $ORG --content-view 'RHEL6_Base' --author saz --name ssh
time hammer content-view publish --organization $ORG --name 'RHEL6_Base' --description 'Initial Publishing' 2>/dev/null
time hammer content-view version promote --organization $ORG --content-view 'RHEL6_Base' --to-lifecycle-environment DEV_RHEL_6  2>/dev/null
echo '#-------------------------------'
echo 'RHEL5 CONTENT VIEW'
echo '#-------------------------------'
hammer content-view create --organization $ORG --name 'RHEL5_Base' --label 'RHEL5_Base' --description 'Core Build for RHEL 5'
hammer content-view add-repository --organization $ORG --name 'RHEL5_Base' --product 'Red Hat Enterprise Linux Server' --repository 'Red Hat Enterprise Linux 5 Server RPMs x86_64 6Server'
hammer content-view add-repository --organization $ORG --name 'RHEL5_Base' --product 'Red Hat Enterprise Linux Server' --repository 'Red Hat Satellite Tools 6.4 for RHEL 5 Server RPMs x86_64'
hammer content-view puppet-module add --organization $ORG --content-view 'RHEL5_Base' --author puppetlabs --name stdlib
hammer content-view puppet-module add --organization $ORG --content-view 'RHEL5_Base' --author puppetlabs --name concat
hammer content-view puppet-module add --organization $ORG --content-view 'RHEL5_Base' --author puppetlabs --name ntp
hammer content-view puppet-module add --organization $ORG --content-view 'RHEL5_Base' --author saz --name ssh
time hammer content-view publish --organization $ORG --name 'RHEL5_Base' --description 'Initial Publishing' 2>/dev/null
time hammer content-view version promote --organization $ORG --content-view 'RHEL5_Base' --to-lifecycle-environment DEV_RHEL_5  2>/dev/null
}
#-------------------------------
#function PUBLISHCONTENT {
#-------------------------------
#source /root/.bashrc
#echo -ne "\e[8;40;170t"
#echo " "
#echo "********************************"
#echo "Publish content view to Library:"
#echo "********************************"
#echo " "
#echo "********************************"
#echo "
#  There may be an error that the (content-view publish) task has failed however the process takes longer to complete than the command timeout.
#Please see https://$(hostname)/content_views/2/versions to watch the task complete.“
# echo "********************************"
# echo " "
# hammer content-view publish --name 'rhel-7-server-x86_64' --organization $ORG --async
# sleep 2000
# echo " "
# echo "*********************************************************"
# echo "Promote content views to DEV_RHEL,TEST_RHEL,PROD_RHEL:"
# echo "*********************************************************"
# hammer content-view version promote --organization $ORG --from-lifecycle-environment ='Library' --to-lifecycle-environment 'DEV_RHEL' --id 2 --async
# sleep 700
# hammer content-view version promote --organization $ORG --from-lifecycle-environment ='DEV_RHEL' --to-lifecycle-environment 'TEST_RHEL' --id 2 --async
# sleep 700
# hammer content-view version promote --organization $ORG --from-lifecycle-environment ='TEST_RHEL' --to-lifecycle-environment 'PROD_RHEL' --id 2 --async
# sleep 700
#}
#-------------------------------
function HOSTCOLLECTION {
#-------------------------------
source /root/.bashrc
echo -ne "\e[8;40;170t"
echo " "
echo "***********************************"
echo "Create a host collection for RHEL:"
echo "***********************************"
hammer host-collection create --name='RHEL 7 x86_64' --organization $ORG
hammer host-collection create --name='CentOS 7 x86_64' --organization $ORG
hammer host-collection create --name='RHEL 5 x86_64' --organization $ORG
hammer host-collection create --name='RHEL 6 x86_64' --organization $ORG
sleep 10
hammer host-collection list --organization $ORG
}
#-------------------------------
function KEYSFORENV {
#-------------------------------
source /root/.bashrc
echo -ne "\e[8;40;170t"
echo " "
echo "*********************************************************"
echo "Create an activation keys for environments:"
echo "*********************************************************"
hammer activation-key create --name 'RHEL7-x86_64' --organization $ORG --content-view='RHEL 7' --lifecycle-environment 'DEV_RHEL_7'
hammer activation-key create --name 'CentOS7-x86_64' --organization $ORG --content-view='CentOS 7' --lifecycle-environment 'DEV_CentOS_7'
#hammer activation-key create --name 'rhel-7-server-x86_64'-DEV_RHEL_7 --organization $ORG --content-view='RHEL7-server-x86_64' --lifecycle-environment 'DEV_RHEL_7'
#sleep 5
#hammer activation-key create --name 'rhel-7-server-x86_64'-TEST_RHEL_7 --organization $ORG --content-view='RHEL7-server-x86_64' --lifecycle-environment 'TEST_RHEL_7'
#sleep 5
#hammer activation-key create --name 'rhel-7-server-x86_64'-PROD_RHEL_7 --organization $ORG --content-view='RHEL7-server-x86_64' --lifecycle-environment 'PROD_RHEL_7'
#sleep 5
}
#-------------------------------
function KEYSTOHOST {
#-------------------------------
source /root/.bashrc
echo -ne "\e[8;40;170t"
echo " "
echo "*********************************************************"
echo "Associate each activation key to host collection:"
echo "*********************************************************"
hammer activation-key add-host-collection --name 'RHEL7-x86_64' --host-collection='RHEL 7 x86_64' --organization $ORG
sleep 5
hammer activation-key add-host-collection --name 'CentOS7-x86_64' --host-collection='CentOS 7 x86_64' --organization $ORG
sleep 5
hammer activation-key add-host-collection --name 'rhel-7-server-x86_64'-PROD_RHEL_7 --host-collection='RHEL 7 x86_64' --organization $ORG
sleep 5
}
#-------------------------------
function SUBTOKEYS {
#-------------------------------
source /root/.bashrc
echo -ne "\e[8;40;170t"
echo " "
echo "********************************"
echo "
  There may be errors in the next step (Could not add subscription to activation key) Please ignore these as
  long as your primary keys for your enabled subscriptions have been added"
  
echo " "
echo "********************************"
echo " "
echo "*********************************************************"
echo "Add all subscriptions available to keys:"
echo "*********************************************************"
for i in $(hammer --csv activation-key list --organization $ORG | awk -F "," {'print $1'} | grep -vi '^ID'); do for j in $(hammer --csv subscription list --organization $ORG | awk -F "," {'print $1'} | grep -vi '^ID'); do hammer activation-key add-subscription --id ${i} --subscription-id ${j}; done; done
}
#-------------------------------
function MEDIUM {
#-------------------------------
source /root/.bashrc
echo -ne "\e[8;40;170t"
echo " "
echo "*********************************************************"
echo "Create Media:"
echo "*********************************************************"
hammer medium create --path=http://repos/${ORG}/Library/content/dist/rhel/server/7/7.6/x86_64/kickstart/ --organizations=$ORG --locations="$LOC" --os-family=Redhat --name="RHEL 7.6 Kickstart" --operatingsystems="RedHat 7.6"
}
#----------------------------------
function VARSETUP2 {
#----------------------------------
source /root/.bashrc
echo -ne "\e[8;40;170t"

ENVIROMENT=$(hammer --csv environment list |awk -F "," {'print $2'}|grep -v Name |grep -v production)
LEL=$(hammer --csv lifecycle-environment list  |awk -F "," {'print $2'} |grep -v NAME)
echo "CAID=1" >> /root/.bashrc
echo "MEDID1=$(hammer --csv medium list |grep 'CentOS 7' |awk -F "," {'print $1'} |grep -v Id)" >> /root/.bashrc
echo "MEDID2=$(hammer --csv medium list |grep 'RHEL 7.6' |awk -F "," {'print $1'} |grep -v Id)" >> /root/.bashrc
echo "SUBNETID=$(hammer --csv subnet list |awk -F "," {'print $1'}| grep -v Id)" >> /root/.bashrc
echo "OSID1=$(hammer os list |grep -i "RedHat 7.6"  |awk -F "|" {'print $1'})" >> /root/.bashrc
echo "OSID2=$(hammer os list |grep -i "CentOS 7.6"  |awk -F "|" {'print $1'})" >> /root/.bashrc
echo "PROXYID=$(hammer --csv proxy list |awk -F "," {'print $1'} |grep -v Id)" >> /root/.bashrc
echo "PARTID=$(hammer --csv partition-table list | grep "Kickstart default" | cut -d, -f1)" >> /root/.bashrc
echo "PXEID=$(hammer --csv template list --per-page=1000 | grep "Kickstart default PXELinux" | cut -d, -f1)" >> /root/.bashrc
echo "SATID=$(hammer --csv template list --per-page=1000 | grep ",Kickstart default,provision" | grep "Kickstart default" | cut -d, -f1)" >> /root/.bashrc
echo "ORGID=$(hammer --csv organization list|awk -F "," {'print $1'}|grep -v Id)" >> /root/.bashrc
echo "LOCID=$(hammer --csv location list|awk -F "," {'print $1'} |grep -v Id)" >> /root/.bashrc
echo "ARCH=$(uname -i)" >> /root/.bashrc
echo "ARCHID=$(hammer --csv architecture list|grep x86_64 |awk -F "," {'print $1'})"  >> /root/.bashrc
echo "DOMID=$(hammer --csv domain list |grep -v Id |grep -v Name |awk -F "," {'print $1'})"  >> /root/.bashrc
echo "SUBNETID=$(hammer --csv subnet list |awk -F "," {'print $1'}| grep -v Id)" >> /root/.bashrc
echo "CVID=$(hammer --csv content-view list --organization $ORG |grep 'RHEL 7' |awk -F "," {'print $1'})" >>  /root/.bashrc
}
#-----------------------------------
function PARTITION_OS_PXE_TEMPLATE {
#-----------------------------------
source /root/.bashrc
echo -ne "\e[8;40;170t"
for i in $OSID
do
hammer partition-table add-operatingsystem --id="${PARTID}" --operatingsystem-id="${i}"
hammer template add-operatingsystem --id="${PXEID}" --operatingsystem-id="${i}"
hammer os set-default-template --id="${i}" --config-template-id="${PXEID}"
hammer os add-config-template --id="${i}" --config-template-id="${SATID}"
hammer os set-default-template --id="${i}" --config-template-id="${SATID}"
done
}
#-------------------------------
function HOSTGROUPS {
#-------------------------------
source /root/.bashrc
echo -ne "\e[8;40;170t"
echo " "
echo "*********************************************************"
echo "Create a RHEL hostgroup(s):"
echo "*********************************************************"
#MAKES ROOTPASSWORD ON NODES rreeddhhaatt BECAUSE THE SYSTEM REQUIRES IT TO BE 8+ CHAR (--root-pass rreeddhhaatt)
ENVIROMENT=$(hammer --csv lifecycle-environment list |awk -F "," {'print $2'}|grep -v Name |grep -v production)
LEL=$(hammer --csv environment list  |awk -F "," {'print $2'}|grep -v Name)
for i in $LEL; do for j in $(hammer --csv environment list |awk -F "," {'print $2'}| awk -F "_" {'print $1'}|grep -v Name); do hammer hostgroup create --name RHEL-7.6-$j --environment $i --architecture-id $ARCHID --content-view-id $CVID --domain-id $DOMID --location-ids $LOCID --medium-id $MEDID1 --operatingsystem-id $OSID1 --organization-id=$ORGID  --partition-table-id $PARTID --puppet-ca-proxy-id $PROXYID --subnet-id $SUBNETID --root-pass=rreeddhhaatt ; done; done
#for i in $LEL; do for j in $(hammer --csv environment list |awk -F "," {'print $2'}| awk -F "_" {'print $1'}|grep -v Name); do hammer hostgroup create --name CentOS-7.6-$j --environment $i --architecture-id $ARCHID --content-view-id $CVID --domain-id $DOMID --location-ids $LOCID --medium-id $MEDID2 --operatingsystem-id $OSID2 --organization-id=$ORGID  --partition-table-id $PARTID --puppet-ca-proxy-id $PROXYID --subnet-id $SUBNETID --root-pass=redhat ; done; done
}
#-------------------------------
function MODPXELINUXDEF {
#-------------------------------
source /root/.bashrc
echo -ne "\e[8;40;170t"
echo " "
echo "*********************************************************"
echo "Setting up and Modifying default template for auto discovery"
echo "*********************************************************"
#sed -i 's/SATELLITE_CAPSULE_URL/'$(hostname)'/g' /usr/share/foreman/app/views/unattended/pxe/PXELinux_default.erb
#hammer template update --id 1
}
#-------------------------------
function ADD_OS_TO_TEMPLATE {
#-------------------------------
source /root/.bashrc
echo -ne "\e[8;40;170t"
echo " "
echo "*********************************************************"
echo "ASSOCIATE OS TO TEMPLATE"
echo "*********************************************************"
hammer template add-operatingsystem --operatingsystem-id 1 --id 1
}

#NOTE You can remove or dissasociate templates Remove is perm (Destricutve) dissasociate you can re associate if you need 

#-------------------------------
function REMOVEUNSUPPORTED {
#-------------------------------
source /root/.bashrc
echo -ne "\e[8;40;170t"
echo " "
echo "*********************************************************"
echo "REMOVING UNSUPPORTED COMPONENTS DESTRUCTIVE"
echo "*********************************************************"
for i in $(hammer template list |grep -i FreeBSD |awk -F "|" {'print $1'}) ; do hammer template delete --id $i ;done
for i in $(hammer template list |grep -i CoreOS |awk -F "|" {'print $1'}) ; do hammer template delete --id $i ;done
for i in $(hammer template list |grep -i salt |awk -F "|" {'print $1'}) ; do hammer template delete --id $i ;done
for i in $(hammer template list |grep -i waik |awk -F "|" {'print $1'}) ; do hammer template delete --id $i ;done
for i in $(hammer template list |grep -i NX-OS |awk -F "|" {'print $1'}) ; do hammer template delete --id $i ;done
for i in $(hammer template list |grep -i Alterator |awk -F "|" {'print $1'}) ; do hammer template delete --id $i ;done
for i in $(hammer template list |grep -i Junos |awk -F "|" {'print $1'}) ; do hammer template delete --id $i ;done
for i in $(hammer template list |grep -i Jumpstart |awk -F "|" {'print $1'}) ; do hammer template delete --id $i ;done
for i in $(hammer template list |grep -i Preseed |awk -F "|" {'print $1'}) ; do hammer template delete --id $i ;done
for i in $(hammer template list |grep -i chef |awk -F "|" {'print $1'}) ; do hammer template delete --id $i ;done
for i in $(hammer template list |grep -i AutoYaST |awk -F "|" {'print $1'}) ; do hammer template delete --id $i ;done
for i in $(hammer partition-table list |grep -i AutoYaST |awk -F "|" {'print $1'}) ; do hammer partition-table delete --id $i ;done
for i in $(hammer partition-table list |grep -i CoreOS |awk -F "|" {'print $1'}) ; do hammer partition-table delete --id $i ;done
for i in $(hammer partition-table list |grep -i FreeBSD |awk -F "|" {'print $1'}) ; do hammer partition-table delete --id $i ;done
for i in $(hammer partition-table list |grep -i Jumpstart |awk -F "|" {'print $1'}) ; do hammer partition-table delete --id $i ;done
for i in $(hammer partition-table list |grep -i Junos |awk -F "|" {'print $1'}) ; do hammer partition-table delete --id $i ;done
for i in $(hammer partition-table list |grep -i NX-OS |awk -F "|" {'print $1'}) ; do hammer partition-table delete --id $i ;done
for i in $(hammer partition-table list |grep -i Preseed |awk -F "|" {'print $1'}) ; do hammer partition-table delete --id $i ;done
for i in $(hammer medium list |grep -i CentOS |awk -F "|" {'print $1'}) ; do hammer medium delete --id $i ;done
for i in $(hammer medium list |grep -i CoreOS |awk -F "|" {'print $1'}) ; do hammer medium delete --id $i ;done
for i in $(hammer medium list |grep -i Debian |awk -F "|" {'print $1'}) ; do hammer medium delete --id $i ;done
for i in $(hammer medium list |grep -i Fedora |awk -F "|" {'print $1'}) ; do hammer medium delete --id $i ;done
for i in $(hammer medium list |grep -i FreeBSD |awk -F "|" {'print $1'}) ; do hammer medium delete --id $i ;done
for i in $(hammer medium list |grep -i OpenSUSE |awk -F "|" {'print $1'}) ; do hammer medium delete --id $i ;done
for i in $(hammer medium list |grep -i Ubuntu |awk -F "|" {'print $1'}) ; do hammer medium delete --id $i ;done
}
#-------------------------------
function DISASSOCIATE_TEMPLATES {
#------------------------------
source /root/.bashrc
echo -ne "\e[8;40;170t"
echo "*********************************************************"
echo "DISASSOCIATE UNSUPPORTED COMPONENTS NONDESTRUCTIVE"
echo "*********************************************************"
echo " "
declare -a TEMPLATES=(
"Alterator default"
"Alterator default finish"
"Alterator default PXELinux"
"alterator_pkglist"
"AutoYaST default"
"AutoYaST default user data"
"AutoYaST default iPXE"
"AutoYaST default PXELinux"
"AutoYaST SLES default"
"chef_client"
"coreos_cloudconfig"
"CoreOS provision"
"CoreOS PXELinux"
"Discovery Debian kexec"
"FreeBSD (mfsBSD) finish"
"FreeBSD (mfsBSD) provision"
"FreeBSD (mfsBSD) PXELinux"
"Jumpstart default"
"Jumpstart default finish"
"Jumpstart default PXEGrub"
"Junos default finish"
"Junos default SLAX"
"Junos default ZTP config"
"NX-OS default POAP setup"
"Preseed default"
"Preseed default finish"
"Preseed default PXEGrub2"
"Preseed default iPXE"
"Preseed default PXELinux"
"Preseed default user data"
"preseed_networking_setup"
"saltstack_minion"
"WAIK default PXELinux"
"XenServer default answerfile"
"XenServer default finish"
"XenServer default PXELinux"
 )
for INDEX in "${TEMPLATES[@]}"
do
echo disassoction of ${INDEX} from ${ORG}@${LOC}
hammer organization remove-config-template --config-template "${INDEX}" --name "${ORG}"
hammer location remove-config-template --config-template "${INDEX}" --name "${LOC}"
done
}
#-------------------------------
function SATUPDATE {
#-------------------------------
echo " "
echo "*********************************************************"
echo "Upgrading/Updating Satellite"
echo "*********************************************************"
echo " "
subscription-manager repos --disable '*'
subscription-manager repos --enable=rhel-7-server-rpms
subscription-manager repos --enable=rhel-server-rhscl-7-rpms
subscription-manager repos --enable=rhel-7-server-satellite-6.4-rpms
subscription-manager repos --enable=rhel-7-server-satellite-maintenance-6-rpms
katello-service stop
katello-selinux-disable
setenforce 0
yum upgrade -y; yum update -y --skip-broken
satellite-installer -v --scenario satellite --upgrade
foreman-rake apipie:cache:index --trace
hammer template build-pxe-default
}
#-------------------------------
function INSIGHTS {
#-------------------------------
yum update python-requests -y
yum install redhat-access-insights -y
redhat-access-insights --register
}

#-------------------------------
function CLEANUP {
#-------------------------------
rm -rf /home/admin/FILES
rm -rf /root/FILES
rm -rf /tmp/*
mv -f /etc/.bashrc.bak /etc/.bashrc
init 6
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

Min Storage 30 GB
DirectoryRecommended
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
          * RHEL_7.6 in a KVM environment.
          * Red Hat subscriber channels:
             rhel-7-server-ansible-2.7-rpms
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
if grep -q -i "release 7.6" /etc/redhat-release ; then
rhel7only=1
echo "RHEL 7.6"
yum --noplugins -q list installed epel-release-latest-7 &>/dev/null && echo "epel-release-latest-7 is installed" || yum install -y https://dl.fedoraproject.org/pub/epel/epel-release-latest-7.noarch.rpm --skip-broken --noplugins
else
echo "Not Running RHEL 7.x !"
fi
echo " "
yum --noplugins -q list installed yum-utils &>/dev/null && echo "yum-utils is installed" || yum install -y yum-utils --skip-broken --noplugins
yum --noplugins -q list installed ansible &>/dev/null && echo "ansible is installed" || yum install -y ansible --skip-broken --noplugins
yum --noplugins -q list installed wget &>/dev/null && echo "wget is installed" || yum install -y wget --skip-broken --noplugins
yum --noplugins -q list installed bash-completion-extras &>/dev/null && echo "bash-completion-extras" || yum install -y bash-completion-extras --skip-broken --noplugins
yum --noplugins -q list installed openssh-clients &>/dev/null && echo "openssh-clients" || yum install -y openssh-clients --skip-broken --noplugins
sleep 10

echo " "
echo '************************************'
echo 'Creating FILES dir here'
echo '************************************'
mkdir -p FILES
cd FILES
pwd
sleep 10

echo " "
echo '************************************'
echo 'Wget Ansible Tower'
echo '************************************'
if grep -q -i "release 7" /etc/redhat-release ; then
 rhel7only=1
echo "RHEL 7 supporting latest release"
wget https://releases.ansible.com/awx/setup/ansible-tower-setup-latest.tar.gz
else
 echo "Not Running RHEL 7.x !"
fi
echo " "
sleep 10

echo " "
echo '************************************'
echo 'Expanding Ansible Tower and installing '
echo '************************************'

cd FILES
tar -zxvf ansible-tower-*.tar.gz
cd ansible-tower*
sed -i 's/admin_password="''"/admin_password="'redhat'"/g' inventory
sed -i 's/redis_password="''"/redis_password="'redhat'"/g' inventory
sed -i 's/pg_password="''"/pg_password="'redhat'"/g' inventory
sed -i 's/rabbitmq_password="''"/rabbitmq_password="'redhat'"/g' inventory
sh setup.sh
}

#--------------------------End Primary Functions--------------------------

#-----------------------
function dMainMenu {
#-----------------------
$DIALOG --stdout --title "Red Hat Sat 6 P.O.C. - RHEL 7.X" --menu "********** Red Hat Tools Menu ********* \n Please choose [1 -> 10]?" 30 90 10 \
1 "Satellite - Prep the system and install Satellite 6.x rpm and Dependencies" \
2 "Satellite - Configure the Satellite scenerio Satellite-Installer" \
3 "Satellite - Choose and Sync Repositories RHEL5, RHEL6, RHEL7, and CUSTOM" \
4 "Satellite - Configure Part 1 sync plan, content view, subnet, hostgroups ect" \
5 "Satellite - Get second variable set" \
6 "Satellite - Part 2 Complete the Configureation Sat 6.X" \
7 "Satellite - Upgrade Sat 6.X" \
8 "Ansible Tower - Install" \
9 "Post install clean up" \
10 "EXIT"
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
1) dMsgBx "Satellite - Prep the system and install Satellite 6.x rpm and Dependencies" \
NETWORK
VARIABLES1
IPA
CAPSULE
SATLIBVIRT
SATRHV
RHVORLIBVIRT
INSTALLREPOS
INSTALLDEPS
GENERALSETUP
INSTALLNSAT
;;
2) dMsgBx "Satellite - Configure the Satellite scenerio Satellite-Installer" \
CONFSAT
HAMMERCONF
CONFIG2
STOPSPAMMINGVARLOG
;;
3) dMsgBx "Satellite - Choose and Sync Repositories RHEL5, RHEL6, RHEL7, CUSTOM" \
REQUEST5
REQUEST6
REQUEST7
REQUESTRHSCL
REQUESTJBOSS
REQUESTVIRTAGENT
REQUESTSAT64
REQUESTOSC
REQUESTCEPH
REQUESTSNC
REQUESTCSI
REQUESTOSP
REQUESTOSPT
REQUESTOSPD
REQUESTRHVH
REQUESTRHVM
REQUESTATOMIC
REQUESTTOWER
REQUESTPUPPET
REQUESTJENKINS
REQUESTMAVEN
REQUESTICINGA
REQUESTCENTOS7
SYNC
;;
4) dMsgBx "Satellite - Configure Part 1 sync plan, content view, subnet, hostgroups ect" \
CREATESUBNET
ENVIRONMENTS
DAILYSYNC
SYNCPLANCOMPONENTS
ASSOCPLANTOPRODUCTS
CONTENTVIEWS
HOSTCOLLECTION
KEYSFORENV
KEYSTOHOST
SUBTOKEYS
MEDIUM
;;
5) dMsgBx "Satellite - Get second variable set" \
VARSETUP2
;;
6) dMsgBx "Satellite - Part 2 Complete the Configureation Sat 6.X" \
PARTITION_OS_PXE_TEMPLATE
HOSTGROUPS
ADD_OS_TO_TEMPLATE
;;
7) dMsgBx "Satellite - Upgrade Sat 6.X" \
SATUPDATE
INSIGHTS
CLEANUP
;;
8) dMsgBx "Ansible Tower - Install" \
ANSIBLETOWER
CLEANUP
;;
9)  dMsgBx "Post install clean up" \
#REMOVEUNSUPPORTED
DISASSOCIATE_TEMPLATES
CLEANUP
;;
10) dMsgBx "*** Exiting Thank you ***"
break
;;
esac

done

exit 0
