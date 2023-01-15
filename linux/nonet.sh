#/bin/bash
#Denies internet access
iptables -D INPUT -p udp --sport 53 -j ACCEPT_LOG
iptables -D OUTPUT -p udp --dport 53 -j ACCEPT_LOG
iptables -D INPUT -p tcp -m multiport --sports 80,443 -j ACCEPT_LOG
iptables -D OUTPUT -p tcp -m multiport --dports 80,443 -j ACCEPT_LOG