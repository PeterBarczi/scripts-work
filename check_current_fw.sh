#!/bin/bash
# Scripts check the actual FW - Dell HW

clear
echo '- - -'
model=`dmidecode |grep -i "Product Name" |grep -ie power | awk '{print $3,$4}'`
serial=`dmidecode -t System |grep 'Serial Number' | awk '{print $3}'`
echo "HW model: $model / $serial"
echo
echo "Here is the current list of installed Firmware: "
echo "-----------------------------------------------"
# NICs FW
echo "NICs FW:"
for i in `/sbin/ip a s |grep BROAD | awk '{print $2}' |tr -d : |grep -ve idrac -ve bond`; do ethtool -i $i|grep -i firmware;done
echo
# BIOS
bios=`dmidecode |grep "BIOS Revision" | awk '{print $3}'`
echo "BIOS: $bios"
echo
# iDRAC
idrac=`ipmitool mc info |grep 'Firmware Revision' | awk '{ print $4}'`
echo "iDRAC: $idrac"
echo
# RAID Controller
controller=`omreport storage controller|grep ^Firmware |grep -v "Not Available" | awk '{print $4}'`
echo "RAID Controller: $controller"
echo '- - -'
