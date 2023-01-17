#!bin/sh

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
echo "Would you like to set all service accounts to /bin/asdfasdf (y/n)?"
read input

# If user input is 'y' => set login shells for UID < 1000 to /bin/asdfasdf
if [ "$input" = "y" ]; then
   echo ""
   echo "Setting all service accounts to /bin/false \n"
   users=$(awk -F: '$3 < 1000 { print $1 }' /etc/passwd)
   for user in $users; do
         if [ "$user" != "root" ]; then
             # If it's not root, change the login shell to /bin/asdfasdf
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
echo "enabled on boot"
chkconfig -list | grep $(runlevel | awk ''):on > /root/baseline/enabledinit.txt
cat /root/baseline/enabledinit.txt

echo ""
echo "File caps"
getcap -r / 2>/dev/null > /root/baseline/filecaps.txt
cat /root/baseline/filecaps.txt/

echo ""
echo "checking for mysql presence"
service mysql status >/dev/null 2>&1
if [ $? -eq 0 ]; then
	echo "mysql found"
	mysql -u root -e "quit" 2>/dev/null
	if [ $? -eq 0 ]; then
		echo "default creds found.. starting backup"
		mysqldump --all-databases > /root/mysql-bak.sql
	fi
fi

echo ""
echo "checking for postgres presence"
service postgresql status >/dev/null 2>&1
if [ $? -eq 0 ]; then
	echo "postgres found"
	psql -U root -c "quit" >/dev/null 2>&1
	if [ $? -eq 0 ]; then
		echo "default creds found.. starting backup"
		pg_dumpall > /root/postgres-bak.sql
	fi
fi

