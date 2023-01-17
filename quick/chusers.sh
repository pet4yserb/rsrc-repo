#!/bin/bash
echo "Backing up passwd/shadow..."
cd && mkdir backups && cp /etc/passwd ~/backups/passwd && cp /etc/shadow ~/backups/shadow && echo "Backed up successfully"
echo Enter Password for users:
read pass
echo Enter box name \(TeamXX_SSH1_PWD\):
read boxname
getent passwd | grep -v '0:0' | cut -d':' -f1 > users.txt
echo "remember to remove admin/services accounts from your users file"
vi users.txt
while IFS=, read -r user; do
    echo "$user:$pass" | /sbin/chpasswd
    echo "Gave $user a password: $pass .";
done < users.txt
sed s/$/,$pass/ users.txt > $boxname
awk '{printf("%s\r\n",$0)}' $boxname > tmp && mv tmp $boxname
