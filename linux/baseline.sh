#!/bin/bash
cd;mkdir baseline;cd baseline
lsmod > loaded_mods
lastlog > lastlog.txt
last > last.txt
netstat -puntal > coninit
ss -4tu > establishedcon.txt
ps aux > procinit
service --status-all > servinit
chkconfig –list | grep $(runlevel | awk ‘’):on >> enabledinit

