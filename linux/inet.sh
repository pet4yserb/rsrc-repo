#/bin/bash
#Allows for outbound internet access
iptables -I INPUT -p udp --sport 53 -j ACCEPT_LOG
iptables -I OUTPUT -p udp --dport 53 -j ACCEPT_LOG
iptables -I INPUT -p tcp -m multiport --sports 80,443 -j ACCEPT_LOG
iptables -I OUTPUT -p tcp -m multiport --dports 80,443 -j ACCEPT_LOG