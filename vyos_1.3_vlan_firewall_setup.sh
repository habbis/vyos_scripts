#!/bin/vbash
source /opt/vyatta/etc/functions/script-template

# based on this guide 
# https://blog.kroy.io/2020/05/04/vyos-from-scratch-edition-1/?utm_source=pocket_mylist#Basic_Configuration

# WAN = eth1
# LAN = eth2

configure

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
set zone-policy zone LAN interface eth2

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
