#REDHATTOOLSINSTALLER

This code is meant to inspire!

This tool was built to aid in the install Red Hat Satellite 6.4 for Proof Of Concept and Education purposes 

This tool was built and tested by the team of :

* Shadd Gallegos of Red Hat 

* Thomas Murphy schonfeld.com

* Rodrique Heron of Red Hat 


Setting up Satellite 6.4^

DISCLAIMER:

#-->DO NOT RUN THIS SCRIPT ON A CURRENTLY PRODUCTION SYSTEM, THIS IS FOR ONLY NEW BUILD OR TEST SYSTEM YOU CAN RE-PROVISION!<-- 


#-->THIS SCRIPT IS NOT SUPPORTED AND THERE IS NO IMPLIED WARRANTY - USE AT OWN RISK!<--


I can set up a full satellite for a P.O.C in 4 hours with


SYSTEM REQUIREMENTS:
* 4 CPU

* 22 GB ram 

* 300 GB storage

* 2 ethernet  
 
    ◦ eth0 internal - provisioning node communication

    ◦ eth1 external - conectiom to Red Hat CDN

OS:

* RHEL 7.6^

Provides: 

* tftp

* dhcp

* dns

* red hat insights

* ansible 

* puppet
      
NOTE: You can shut any service you dont want after the install 


I believe all products should have an "installer" that guides endusers to success. 

What this does is:

* reduces TtP (time to productivity)

* reduction in deployment cost

* reduction in support costs

* increase in margin

* easy to reproduce 

* easy to deploy 
      
Setting up satellite 6.x can be quite diffacult, between the documentation and the speed at which the product developed can make it trick to deploy and adopt. I want to make it easier 

This works in a graphical or headless environment to help you install red hat satellite 6.4 and the latest ansible tower.

The script does use the epel to install components needed to run the script and i have provided the xdialog rpm if you want it to run the cool dialog box.

WHO IS THIS SCRIPT FOR?

* Anyone who wants to set up a proof of concept system or and admin that wants to deploy satellite quickly    
* Anyone that wants to make the Red Hat experiance an even better one 

ANY ISSUES?:
kind of -> what i mean by that is because it does use some of the epel components it does step outside of the red hat soe (standard operating enviroment) but you can remove those after the fact if you want.

I wanted to get this script out for people to use, so you will need to take a close look at the content-views section of the script. 

* You will need to decide naming convention for your content views. Some endusers do it by product (rhel5,rhel6,rhel7) some users do it by a product (docker,webservers,security, customer name,ect…)

* You then will need to decide which repos you want to add for the content views

* You will need to define any custom repos i have added a few so you can see how it works (icinga, epel, maven, centos, ect…)
  
