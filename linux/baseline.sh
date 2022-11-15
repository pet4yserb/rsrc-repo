#!/bin/sh

echo "\033[32mSTARTING BASELINE SCRIPT..\033[0m"

echo ""
echo "\033[31mSYSTEM INFO \033[0m"
echo "\033[33m[+] Hostname: \033[0m" $(hostname)
echo "\033[33m[+] IP Address(es): \033[0m" 
ip addr | grep -o 'inet .*'
echo ""

echo "\033[33mWould you like to set all service accounts to /bin/false (y/n)?\033[0m"
read input

# If user input is 'y' => set login shells for UID < 1000 to /bin/false || /usr/sbin/nologin
if [ "$input" = "y" ]; then
   echo ""
   echo "Setting all service accounts to /bin/false \n"
   users=$(awk -F: '$3 < 1000 { print $1 }' /etc/passwd)
   for user in $users; do
         if [ "$user" != "root" ]; then
             # If it's not root, change the login shell to /bin/false or /usr/sbin/nologin
             chsh -s /bin/false $user
         fi
   done
else
    echo "\033[33mIgnoring service account login shell for now.. \033[0m"
fi

# Finds all UID 0 accounts
echo ""
echo "\033[31mUID 0 accounts: \033[0m"
echo $(getent passwd | grep '0:0' | cut -d':' -f1)

# Find all users w/ sudo privs
echo ""
echo "\033[31mUsers with sudo privs: \033[0m"
grep -E '^[^#%@]*\b(ALL|(S|s)udoers)\b' /etc/sudoers

# SUID binaries
echo ""
echo "\033[31mSUID binaries: \033[0m"
find / -uid 0 -perm -4000 -print

# Current user sessions
echo ""
echo "\033[31mCurrent user sesssions: \033[0m"
w -h

# Listening processes
echo ""
echo "\033[31mListening processes \033[0m"
netstat -lntp | grep :
