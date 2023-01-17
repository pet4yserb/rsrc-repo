#!bin/bash

declare -A closed_counts

# Set the list of ports and IPs to scan
ports="22 25 80 110 143 443 8000"
ips="10.42.0.161 10.42.0.7"

# Set the number of consecutive checks before sending an email
checks_before_alert=3

# Set the email address to send alerts to
alert_email="root@dev.ziglab.local"

function quit {
        echo "ctrl+c detected.. quitting now"
        exit 1
}

trap quit SIGINT

echo "[INFO] starting availability checker [INFO]"

# Loop forever, scanning the ports and IPs every 30 seconds
while true; do
    # Loop over each IP address
    for ip in $ips; do
        # Loop over each port	
	echo "-------------------------------------------"
	echo "-------------  $ip  ---------------"
        for port in $ports; do
            # Check if the port is open or closed
            if nc -w 2 -z $ip $port; then
                echo "[+] port $port/tcp is open on $ip [+]"
            else
                echo "[!] port $port/tcp is closed on $ip [!]"
                # Increment the counter for this port and IP
                ((closed_counts["$ip:$port"]++))
            fi
        done
    done

    # Check if any ports have been closed for too many checks
    for key in "${!closed_counts[@]}"; do
        # Get the IP address and port from the key
        ip=${key%:*}
        port=${key#*:}

        # Check if the port has been closed for too many checks
        if ((closed_counts[$key] >= checks_before_alert)); then
            # Send an alert email
            echo "Port $port/tcp on $ip has been closed for more than $checks_before_alert checks." | mail -s "Port alert" $alert_email
            echo "[ALERT] mail sent for port $port on $ip [ALERT]"
            # Reset the counter for this port and IP
            unset closed_counts["$key"]
        fi
    done
    echo ""
    echo "[INFO] scan complete... next scan in 30s [INFO]"
    # Wait for 30 seconds before scanning the ports and IPs again
    sleep 30
done
