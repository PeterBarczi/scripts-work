#!/bin/bash

for ip in `cat serverlist`; 
do
echo $ip
timeout 5 ./racadm -u root -p calvin -r $ip --nocertwarn getsysinfo | grep Ethernet | sort |  awk '{print $1,$4}'
echo "---"
done
