import ipaddress
from pssh.clients import ParallelSSHClient
from pssh.exceptions import Timeout
hosts = []

def GenerateIPs():
    for ip in ipaddress.IPv4Network('10.0.0.0/24'):
        #print(str(ip))
        hosts.append(str(ip))
    print("Added "+str(len(hosts))+" IPs to the host list...")

GenerateIPs()

#If you get errors,increase the timeout value below
client = ParallelSSHClient(hosts,user='root',password='test',timeout=1,num_retries=0)
#change the password you want to change set below
output = client.run_command('echo "root:test2" | chpasswd && echo "Gave root a password: test2 ";',stop_on_errors=False,sudo=True)
client.join()
for host_output in output:
    hostname = host_output.host
    try:
        stdout = list(host_output.stdout)
        print("Host %s: exit code %s, output %s" % (
              hostname, host_output.exit_code, stdout))
    except Exception:
        pass
