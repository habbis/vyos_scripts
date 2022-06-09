#!/bin/vbash
source /opt/vyatta/etc/functions/script-template

# based on this guide 
# https://blog.kroy.io/2020/05/04/vyos-from-scratch-edition-1/?utm_source=pocket_mylist#Basic_Configuration

interface_address="10.31.1.1"
dhcp_address="10.31.1.0"
nameserver1="10.31.1.1"
subnet="24"
dhcp_start="10.31.1.50"
dhcp_end="10.31.1.200"

interface="eth4"
wan_interface="eth1"

configure

# set interface address
set interfaces ethernet $interface address $interface_address/$subnet
set interfaces ethernet $interface description LAN    

commit
save

# dhcp server config 
set service dhcp-server shared-network-name LAN subnet $dhcp_address/$subnet range 0 start $dhcp_start
set service dhcp-server shared-network-name LAN subnet $dhcp_address/$subnet range 0 stop  $dhcp_end

# dns for dhcp server
set service dhcp-server shared-network-name LAN subnet $dhcp_address/$subnet nameserver-server $interface_address
set service dhcp-server shared-network-name LAN subnet $dhcp_address/$subnet default-router $interface_address

# set ssh port 
set service ssh port 22
commit
save

# setup nat 
# setup nat 
# 16 subnet so you dont need to make a rule for each 24 subnet
set nat source rule 100 source address '10.31.0.0/16'
set nat source rule 100 outbound-interface $wan_interface
set nat source rule 100 translation address masquerade
commit
save

set service dns forwarding listen-address $nameserver1
set service dns forwarding allow-from 10.31.1.0/16
set service dns forwarding cache-size '0'
commit
save

# dns forwarding
set service dns forwarding name_server 1.1.1.1
set service dns forwarding name_server 1.0.0.1
set service dns forwarding name_server 8.8.8.8
set service dns forwarding name_server 8.8.4.4
commit
save

# system dns
set system name-server $nameserver1
commit
save

# firewall
conf
set firewall name LAN-WAN default-action accept
set firewall name LAN-LOCAL default-action accept
commit
save

# locale rules
conf
set firewall name LOCAL-WAN default-action accept
set firewall name LOCAL-LAN default-action accept
commit
save

# wan default rules
set firewall name WAN-LOCAL default-action drop
set firewall name WAN-LOCAL rule 5 action accept
set firewall name WAN-LOCAL rule 5 state established enable
set firewall name WAN-LOCAL rule 5 state related enable
set firewall name WAN-LOCAL rule 5 description "Allow EST/Related Traffic"
commit
save

# allow icmp
set firewall name WAN-LOCAL rule 20 protocol icmp
set firewall name WAN-LOCAL rule 20 state new enable
set firewall name WAN-LOCAL rule 20 action accept
commit
save


set firewall name WAN-LAN default-action drop
set firewall name WAN-LAN rule 5 action accept
set firewall name WAN-LAN rule 5 state established enable
set firewall name WAN-LAN rule 5 state related enable
set firewall name WAN-LAN rule 5 description "Allow EST/Related Traffic"
set firewall name WAN-LAN rule 20 protocol icmp
set firewall name WAN-LAN rule 20 state new enable
set firewall name WAN-LAN rule 20 action accept

# zone rules

set zone-policy zone LAN default-action drop
set zone-policy zone LAN from WAN firewall name WAN-LAN
set zone-policy zone LAN from LOCAL firewall name LOCAL-LAN
set zone-policy zone LAN interface $interface

set zone-policy zone LOCAL local-zone
set zone-policy zone LOCAL from LAN firewall name LAN-LOCAL
set zone-policy zone LOCAL from WAN firewall name WAN-LOCAL
set zone-policy zone LOCAL default-action drop


set zone-policy zone WAN from LAN firewall name LAN-WAN
set zone-policy zone WAN from LOCAL firewall name LOCAL-WAN
set zone-policy zone WAN interface $wan_interface
set zone-policy zone WAN default-action drop

# wan interface dhcp
set interfaces ethernet $wan_interface address dhcp
set interfaces ethernet $wan_interface description WAN

commit
save

exit
