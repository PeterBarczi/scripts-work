#!/bin/bash
#

clear
# Vars
int=idrac
count_squid=$(ps -ef |grep sbin/squid |grep -v grep |wc -l)
#squid_pkg=$(rpm -qa |grep squid- |wc -l)
squid_pkg=0

## Pre-checks
# 1. Do NOT overwrite squid.conf if already running there
if [ $count_squid -ne 0 ] || [ $squid_pkg -ne 0 ];
  then
    echo
    echo ">>> Stopping.... "
    echo "SQUID Detected! Check its configuration..!"
    echo
    exit 1
fi
# 2. Test if idrac interface is present or not
echo "----------------"
echo "idrac NIC IP: "
echo "----------------"
ifconfig idrac |grep inet | awk '{ print $2'} |grep 169.
if [ $? -ne 0 ];
  then
    echo ">>> Stopping.... "
    echo "idrac NIC not detected!"
    echo
    exit 1
fi
# End of pre-checks

## Continue
# Choose Location
echo "----------------"
echo "Select LOCATION: "
echo "----------------"
echo  "1) FFM"
echo  "2) MGD/BIERE"
echo  "3) Quit without any action."
echo
echo -n "Enter your Choice: "
read choice

# Set proxy IP based on choosen Location
case $choice in

        1 | FFM )
                location=Frankfurt
                proxy=6.151.101.242
                port=3128
                ;;

        2 | MGD | BIERE )
                location=Magdeburg
                proxy=6.152.4.110
                port=3128
                ;;

        3) exit 1
            ;;

        *) echo "Invalid input!"
            ;;
esac
echo
echo "Your choice:"
echo "Location: $location with $proxy."
# Install SQUID
echo
echo ">> Installing SQUID...."
echo
yum -y install squid

# Adjust squid.conf
sudo cat <<EOF > /etc/squid/squid.conf
# idrac Subnet
acl localnet src 169.254.0.0/16 # RFC1918 possible internal network

# Parent PROXY
cache_peer $proxy parent $port 0 no-query default
acl all src all
http_access allow all
never_direct allow all

# Allowed Ports
acl SSL_ports port 443
acl Safe_ports port 80          # http
acl Safe_ports port 443         # https
acl CONNECT method CONNECT

http_access deny !Safe_ports
http_access deny CONNECT !SSL_ports
http_access allow localhost manager
http_access deny manager
http_access allow localnet
http_access allow localhost
http_access deny all
# Listen
http_port 169.254.0.2:3128

coredump_dir /var/spool/squid

refresh_pattern ^ftp:           1440    20%     10080
refresh_pattern ^gopher:        1440    0%      1440
refresh_pattern -i (/cgi-bin/|\?) 0     0%      0
refresh_pattern .               0       20%     4320
EOF

# Restart Service
echo
echo ">> Starting Service..."
systemctl start squid
echo "Squid is"
systemctl is-active squid
# END
