start /d IEXPLORE.EXE https://www.mozilla.org/en-US/firefox/download/thanks/

schtasks > C:\Users\Administrator\Desktop\schtasks-start.txt
schtasks /delete /TN * /F
netsh advfirewall set allprofiles state off
netsh advfirewall export "C:\Users\Administrator\Desktop\starting-FW.wfw"
netsh advfirewall firewall delete rule name=all

netsh advfirewall firewall add rule name=localhost dir=in action=allow localip=127.0.0.1
netsh advfirewall firewall add rule name=LAN dir=in action=allow remoteip=172.20.0.0/16
netsh advfirewall firewall add rule name=DNS dir=in action=allow protocol=UDP localport=53
netsh advfirewall firewall add rule name=Kerberos dir=in action=allow protocol=TCP localport=88
netsh advfirewall firewall add rule name=LDAP dir=in action=allow protocol=TCP localport=389
netsh advfirewall firewall add rule name=SMTP dir=in action=allow protocol=TCP localport=25
netsh advfirewall firewall add rule name=POP3 dir=in action=allow protocol=TCP localport=110
netsh advfirewall firewall add rule name=HTTP dir=in action=allow protocol=TCP localport=80


netsh advfirewall firewall add rule name=localhost dir=out action=allow localip=127.0.0.1
netsh advfirewall firewall add rule name=HTTP dir=out action=allow protocol=UDP remoteport=80
netsh advfirewall firewall add rule name=HTTPS dir=out action=allow protocol=UDP remoteport=443
netsh advfirewall firewall add rule name=DNS dir=out action=allow protocol=UDP remoteport=53
netsh advfirewall firewall add rule name=LAN dir=out action=allow remoteip=172.20.0.0/16
netsh advfirewall firewall add rule name=NTP dir=out action=allow protocol=TCP localport=123 remoteip=172.20.240.20
netsh advfirewall firewall add rule name=Splunk dir=out action=allow remoteip=172.20.240.20 

netsh advfirewall set allprofiles firewallpolicy blockinbound,blockoutbound
netsh advfirewall set allprofiles state on


netsh advfirewall set Domainprofile logging filename %systemroot%\system32\LogFiles\Firewall\pfirewall.log
netsh advfirewall set Domainprofile logging maxfilesize 4096
netsh advfirewall set Domainprofile logging droppedconnections enable
netsh advfirewall set Domainprofile logging allowedconnections enable

netsh advfirewall set Privateprofile logging filename %systemroot%\system32\LogFiles\Firewall\pfirewall.log
netsh advfirewall set Privateprofile logging maxfilesize 4096
netsh advfirewall set Privateprofile logging droppedconnections enable
netsh advfirewall set Privateprofile logging allowedconnections enable

netsh advfirewall set Publicprofile logging filename %systemroot%\system32\LogFiles\Firewall\pfirewall.log
netsh advfirewall set Publicprofile logging maxfilesize 4096
netsh advfirewall set Publicprofile logging droppedconnections enable
netsh advfirewall set Publicprofile logging allowedconnections enable

cd C:\Windows\System32
takeown /f sethc.exe
icacls sethc.exe /deny “BUILTIN\Users”:F
icacls sethc.exe /deny “BUILTIN\Administrators”:F

takeown /f utilman.exe
icacls utilman.exe /deny “BUILTIN\Users”:F
icacls utilman.exe /deny “BUILTIN\Administrators”:F

takeown /f osk.exe
icacls osk.exe /deny “BUILTIN\Users”:F
icacls osk.exe /deny “BUILTIN\Administrators”:F

takeown /f magnify.exe
icacls magnify.exe /deny “BUILTIN\Users”:F
icacls magnify.exe /deny “BUILTIN\Administrators”:F

takeown /f AtBroker.exe
icacls AtBroker.exe /deny “BUILTIN\Users”:F
icacls AtBroker.exe /deny “BUILTIN\Administrators”:F

takeown /f DisplaySwitch.exe
icacls DisplaySwitch.exe /deny “BUILTIN\Users”:F
icacls DisplaySwitch.exe /deny “BUILTIN\Administrators”:F
