#!/bin/vbash
source /opt/vyatta/etc/functions/script-template

# based on this guide 
# https://blog.kroy.io/2020/05/04/vyos-from-scratch-edition-1/?utm_source=pocket_mylist#Basic_Configuration

# WAN = eth1
# LAN = eth2

configure

# vlan home_300_osl
set interface ethernet eth2 vif 300
set interfaces ethernet eth2 vif 300 address 172.1.300.1/24
set interfaces ethernet eth2 vif 300  description home_300_osl
# vlan office_301_osl
set interface ethernet eth2 vif 301
set interfaces ethernet eth2 vif 301 address 172.1.301.1/24
set interfaces ethernet eth2 vif 301  description office_301_osl

# vlan bastion_302_osl
set interface ethernet eth2 vif 302
set interfaces ethernet eth2 vif 302 address 172.1.302.1/24
set interfaces ethernet eth2 vif 302  description bastion_302_osl


commit
save

exit
