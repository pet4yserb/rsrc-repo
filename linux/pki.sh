#!/bin/sh

echo "^-^/ hello welcome to this dank pki script"
echo "creating directories for certs n keys!"
echo ""

mkdir /etc/pki
mkdir /etc/pki/ca
mkdir /etc/pki/ca/certs
mkdir /etc/pki/ca/private
mkdir /etc/pki/tls
mkdir /etc/pki/tls/certs
mkdir /etc/pki/tls/private
mkdir /etc/pki/tls/csr

read -p "do you want a root ca? (y/n): " input

if [ "$input" = "y" ]; then
	echo ""
	echo "generating root.key and root.crt"
	echo "[!] starting key creation [!]"
	openssl genrsa -aes128 -out /etc/pki/ca/private/root.key 2048
	echo "[+] key created [+]"
	echo "[!] starting cert creation [!]"
	openssl req -new -x509 -days 1825 -key /etc/pki/ca/private/root.key -out /etc/pki/ca/certs/root.crt
	echo "[+] cert created [+]"
else
	echo "ok. skipping for now."
fi



hostnames=()
echo ""
echo "alright gang time to get some server certs"
echo "*type 'quit' to exit server-cert-prompt anytime*"
while true; do
	read -p "enter the hostname for the cert: " input
	if [ "$input" = "quit" ]; then
		break
    	else
		hostnames+=($input)
		echo "[!] starting key creation for $input [!]"
        	openssl genrsa -out /etc/pki/tls/private/$input.key 1024
		echo "[+] key created [+]"
		echo "[!] starting csr creation for $input [!]"
		openssl req -new -key /etc/pki/tls/private/$input.key -out /etc/pki/tls/csr/$input.csr
		echo "[+] csr created [+]"
		echo "[**] signing $input.csr with root [**]"
		openssl x509 -req -in /etc/pki/tls/csr/$input.csr -CA /etc/pki/ca/certs/root.crt -CAkey /etc/pki/ca/private/root.key -CAcreateserial -out /etc/pki/tls/certs/$input.crt -days 365
		echo "[+] $input.crt created at /etc/pki/tls/certs [+]"
	fi
done

read -p "[?] wanna start a py server so the homies can grab it (y/n) [?]" input
if [ "$input" = "y" ]; then
	echo "^-^! ok. creating dir to share, adding port 8000 to iptables, tarballing keys + certs"
	mkdir /root/supasecret
	for host in "${hostnames[@]}"
	do
		echo "[+] creating tar.gz for $host [+]"
		tar czf /root/supasecret/$host.tar.gz /etc/pki/tls/certs/$host.crt /etc/pki/tls/private/$host.key
	done
	
	cd /root/supasecret	
	iptables -A INPUT -p tcp --dport 8000 -m state --state NEW,ESTABLISHED -j ACCEPT_LOG
	iptables -A OUTPUT -p tcp --sport 8000 -m state --state NEW,ESTABLISHED -j ACCEPT_LOG
	command -v python3 >/dev/null 2>&1 && python3 -m http.server 8000 || echo "python3 not found."
	command -v python2.7 >/dev/null 2>&1 && python2.7 -m SimpleHTTPServer 8000 || echo "python2.7 mot found."

fi

echo "peace gang o7"
