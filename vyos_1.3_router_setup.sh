
#!/bin/vbash
source /opt/vyatta/etc/functions/script-template

# based on this guide 
# https://blog.kroy.io/2020/05/04/vyos-from-scratch-edition-1/?utm_source=pocket_mylist#Basic_Configuration

# WAN = eth1
# LAN = eth4

configure

# set interface address
set interfaces ethernet eth4 address 10.31.1.1/24
set interfaces ethernet eth4 description LAN    

commit
save

# dhcp server config 
set service dhcp-server shared-network-name LAN subnet 10.31.1.0/24 range 0 start 10.31.1.50
set service dhcp-server shared-network-name LAN subnet 10.31.1.0/24 range 0 stop  10.31.1.200

# dns for dhcp server
set service dhcp-server shared-network-name LAN subnet 10.31.1.0/24 name-server 10.31.1.1
set service dhcp-server shared-network-name LAN subnet 10.31.1.0/24 default-router 10.31.1.1

# set ssh port 
set service ssh port 22
commit
save

# setup nat 
# setup nat 
# 16 subnet so you dont need to make a rule for each 24 subnet
set nat source rule 100 source address '10.31.0.0/16'
set nat source rule 100 outbound-interface eth1
set nat source rule 100 translation address masquerade
commit
save

set service dns forwarding listen-address 10.31.1.1
set service dns forwarding allow-from 10.31.0.0/16
set service dns forwarding cache-size '0'
commit
save

# dns forwarding
set service dns forwarding name-server 1.1.1.1
set service dns forwarding name-server 1.0.0.1
set service dns forwarding name-server 8.8.8.8
set service dns forwarding name-server 8.8.4.4
commit
save

# system dns
set system name-server 10.31.1.1
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
set zone-policy zone LAN interface eth4

set zone-policy zone LOCAL local-zone
set zone-policy zone LOCAL from LAN firewall name LAN-LOCAL
set zone-policy zone LOCAL from WAN firewall name WAN-LOCAL
set zone-policy zone LOCAL default-action drop


set zone-policy zone WAN from LAN firewall name LAN-WAN
set zone-policy zone WAN from LOCAL firewall name LOCAL-WAN
set zone-policy zone WAN interface eth1
set zone-policy zone WAN default-action drop

# wan interface dhcp
set interfaces ethernet eth1 address dhcp
set interfaces ethernet eth1 description WAN

commit
save

exit
