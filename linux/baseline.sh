#!/bin/sh

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
echo "Would you like to set all service accounts to /bin/shit (y/n)?"
read input

# If user input is 'y' => set login shells for UID < 1000 to /bin/shit
if [ "$input" = "y" ]; then
   echo ""
   echo "Setting all service accounts to /bin/false \n"
   users=$(awk -F: '$3 < 1000 { print $1 }' /etc/passwd)
   for user in $users; do
         if [ "$user" != "root" ]; then
             # If it's not root, change the login shell to /bin/shit
             chsh -s /bin/false $user
         fi
   done
else
    echo "Ignoring service account login shells for now.."
fi

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
netstat -puntal > /root/baseline/netstatinit.txt
cat /root/baseline/netstatinit.txt

echo ""
echo "processes"
ps aux --forest > /root/baseline/procs.txt
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