#This script performs an archival of important Linux OS directories

#!/bin/bash
cd /root
mkdir thicc
cd /
folders="etc var root home sbin bin opt"
for dir in $folders
do
	tar czvfp /root/thicc/${dir}.tgz ${dir}
done
cp -p -r /var/www/ /root/thicc/wwwbckp
tar czvfp $(hostname).tgz thicc 
