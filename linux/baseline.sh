#!/bin/bash

echo "STARTING BASELINE SCRIPT..."
mkdir /root/baseline

echo ""
echo "SYSTEM INFO"
echo "Hostname: $(hostname)"
echo "[+] IP Address(es):" 
ip addr | grep -o 'inet .*' 
echo ""
# Current user sessions
echo "Current user sesssions:"
w -h

echo ""
echo "Setting all service accounts to /bin/noshellforu \n"
users=$(awk -F: '$3 < 1000 { print $1 }' /etc/passwd)
for user in $users; do
    if [ "$user" != "root" ]; then
	chsh -s /bin/noshellforu $user
    fi
done

# Finds all UID 0 accounts
echo ""
echo "UID 0 accounts:"
getent passwd | grep '0:0' | cut -d':' -f1 > /root/baseline/uid0.txt
cat /root/baseline/uid0.txt

# Find all users w/ sudo privs
echo ""
echo "Users with sudo privs:"
grep -E '^[^#%@]*\b(ALL|(S|s)udoers)\b' /etc/sudoers > /root/baseline/sudoers.txt
cat /root/baseline/sudoers.txt

# SUID binaries
echo ""
echo "SUID binaries:"
find / -uid 0 -perm -4000 -print 2>/dev/null > /root/baseline/suid-binaries.txt
cat /root/baseline/suid-binaries.txt

# Listening processes
echo ""
echo "Connections"
netstat -puntal > /root/baseline/procinit.txt
cat /root/baseline/procinit.txt

echo ""
echo "processes"
ps aux > /root/baseline/procs.txt
cat /root/baseline/procs.txt

echo ""
echo "established connections"
ss -4tu > /root/baseline/established-conns.txt
cat /root/baseline/established-conns.txt

echo ""
echo "enabled?"
chkconfig -list | grep $(runlevel | awk ''):on > /root/baseline/enabledinit.txt
cat /root/baseline/enabledinit.txt

echo ""
echo "File caps"
getcap -r / 2>/dev/null > /root/baseline/filecaps.txt
cat /root/baseline/filecaps.txt

echo ""
echo "Adding iptables rules"

iptables() {
    /sbin/iptables "$@"
}

iptables -N ACCEPT_LOG
iptables -A ACCEPT_LOG -j LOG --log-level 6 --log-prefix ':accept_log:'
iptables -A ACCEPT_LOG -j ACCEPT
iptables -N DROP_LOG
iptables -A DROP_LOG -j LOG --log-level 6 --log-prefix ':drop_log:'
iptables -A DROP_LOG -j DROP

# Allowed ports array
allowed_ports=("20" "21" "22" "25" "53" "80" "110" "143" "443" "8080")

# Get listening ports and protocols using netstat
listening_ports=$(netstat -tuln | awk 'NR>2 {split($4, a, ":"); print $1, a[2]}' | sort -u)

# Iterate through the listening ports and add iptables rules if the port is in the allowed_ports array
while IFS= read -r line; do
    protocol=$(echo "$line" | awk '{print $1}')
    port=$(echo "$line" | awk '{print $2}')

    if [[ " ${allowed_ports[*]} " == *" $port "* ]]; then
        if [[ "$protocol" == "tcp" ]]; then
            echo "adding iptables rule for $protocol/$port"
            iptables -A INPUT -p tcp --dport $port -m state --state NEW,ESTABLISHED -j ACCEPT_LOG
            iptables -A OUTPUT -p tcp --sport $port -m state --state ESTABLISHED -j ACCEPT_LOG
        elif [[ "$protocol" == "udp" ]]; then
            echo "adding iptables rule for $protocol/$port"
            iptables -A INPUT -p udp --dport $port -m state --state NEW,ESTABLISHED -j ACCEPT_LOG
            iptables -A OUTPUT -p udp --sport $port -m state --state ESTABLISHED -j ACCEPT_LOG
        fi
    else
        echo "ignoring iptables rule for $protocol/$port"
    fi
done <<< "$listening_ports"

team_number=$(ip addr | grep -o 'inet .*' | sed -n -e 's/^inet //p' | grep -v '127.0.0.1' | head -n 1 | awk -F '[./ ]' '{print substr($2, 1, 1)}')
local_net="10.${team_number}0.${team_number}0.0/24"
local_esxi="172.16.${team_number}0.0/24"
remote_esxi="172.16.${team_number}5.0/24"

echo "adding iptables rules for $local_net, $local_esxi, $remote_esxi"

# scoring / comp services
iptables -A INPUT -s 10.120.0.0/16 -j ACCEPT
iptables -A OUTPUT -d 10.120.0.0/16 -j ACCEPT
iptables -A INPUT -s $local_net -j ACCEPT
iptables -A OUTPUT -d $local_net -j ACCEPT
iptables -A INPUT -s $local_esxi -j ACCEPT
iptables -A OUTPUT -d $local_esxi -j ACCEPT
iptables -A INPUT -s $remote_esxi -j ACCEPT
iptables -A OUTPUT -d $remote_esxi -j ACCEPT

iptables -A OUTPUT -o lo  -j ACCEPT
iptables -A INPUT -i lo -j ACCEPT
iptables -A INPUT -j DROP_LOG
iptables -A OUTPUT -j DROP_LOG

echo "iptables rules added."

echo ""
echo "starting backups"

mkdir /root/thicc
cd /
folders="etc var root home sbin bin opt"
for dir in $folders; do
    tar czvfp /root/thicc/${dir}.tgz ${dir}
done
cp -p -r /var/www/ /root/thicc/wwwbckp
tar czvfp $(hostname).tgz thicc

echo "backup complete"

echo ""
echo "changing root & sysadmin pwd"
echo "root:ILoveCCDCSoMuch123!" | /sbin/chpasswd
echo "sysadmin:ScriptJunkiePlzDontPopThis123!" | /sbin/chpasswd

rm -- "$0"
