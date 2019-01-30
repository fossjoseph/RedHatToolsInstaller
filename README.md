# RedHatToolsInstaller
This code is ment to inspire!
** DO NOT RUN THIS SCRIPT ON A CURRENNTLY PRODUCTION SYSTEM, THIS IS FOR ONLY NEW BUILD OR TEST SYSTEM YOU CAN REPROVISION**
**This script is not supported and there is no implied warrenty - use at own risk**
I can set up a full Satellite for a POC in 4 hours with
  4 CPU 
  22 GB RAM 
  300 GB Storage
  2 ethernet  
    eth0 Internal - provisioning node communication
    eth1 External - Conectiom to RedHat CDN
    
OS:
  RHEL 7.6^

Provides 
   TFTP
   DHCP
   DNS
   Red Hat Insights
   Ansible 
   Puppet
   And you can shut any service you dont want after the install 

I believe all products should have an "installer" that guides endusers to success. 
What this does is:
    Reduces TtP (Time to Productivity)
    Reduction in deployment cost
    Reduction in support costs
    Increase in margin 
    Easy to reproduce 
    Easy to deploy 

Setting up Satellite 6.x can be quite diffacult, between the documentation and the speed at which the product developed can make it trick to deploy and adopt. I want to make it easier 

This works in a graphical or headless environment to help you install Red Hat Satellite 6.4 and the latest Ansible Tower.

The Script does use the EPEL to install components needed to run the script and I have provided the xdialog rpm if you want it to run the cool dialog box.

Who is the script for?
Anyone who wants to set up a Proof of Concept system or and admin that wants to deploy Satellite quickly 

Issues?
Kind of -> what I mean by that is because it does use some of the epel components it does step outside of the Red Hat SOE (Standard Operating Enviroment) but you can remove those after the fact if you want.

I wanted to get this script out for people to use so you will need to take a close look at the CONTENT-VIEWS section of the script. 
  1. You will need to decide Naming convention for your content views. Some endusers do it by Product (RHEL5,RHEL6,RHEL7) Some users do it by a product (Docker,Webservers,Security, Customer Name,ect...)
  2. You then will need to decide which repos you want to add for the content views
  
  3. You will need to define any custom repos I have added a few so you can see how it works (Icinga, EPEL, Maven, CentOS, ECT...)
  
If you need help or want to implement satellite or any other RedHat tool contact me and I am glad to assist. 

Your Friend

Shadd Gallegos
Senior Solutions Architect
shadd@redhat.com
