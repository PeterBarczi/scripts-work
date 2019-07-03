#!/bin/bash
# Script configures iDRAC settings

# Define IP & VLAN ID
ip=6.153.222.40
vlan=2979



echo "IP: $ip - checking nic.nicconfig.1.legacybootproto PXE"
# Verify it's set to PXE
#racadm -u root -p calvin -r 6.153.222.34 --nocertwarn  get nic.nicconfig.1 | grep Legacy
# servers's iDRAC -> Configuration -> BIOS Settings -> Network Settings -> PXE Device1, PXE Device2
./racadm -u root -p calvin -r $ip --nocertwarn  get nic.nicconfig.1 | grep Legacy
./racadm -u root -p calvin -r $ip --nocertwarn  get nic.nicconfig.2 | grep Legacy
./racadm -u root -p calvin -r $ip --nocertwarn set nic.nicconfig.2.LegacyBootProto PXE


# setup VLAN for PXE
echo "IP: $ip - setting booting over PXE VLAN $vlan"
./racadm -u root -p calvin -r $ip --nocertwarn set nic.nicconfig.1.VLanMode Enabled
./racadm -u root -p calvin -r $ip --nocertwarn set nic.nicconfig.1.VLanId $vlan
./racadm -u root -p calvin -r $ip --nocertwarn set nic.nicconfig.2.VLanMode Enabled
./racadm -u root -p calvin -r $ip --nocertwarn set nic.nicconfig.2.VLanId $vlan
./racadm -u root -p calvin -r $ip --nocertwarn config -g cfgServerInfo -o cfgServerBootOnce 1
./racadm -u root -p calvin -r $ip --nocertwarn config -g cfgServerInfo -o cfgServerFirstBootDevice PXE

# servers's iDRAC -> Configuration -> BIOS Settings-> Boot Settings
# get bios.biosbootsettings.BootMode
./racadm -u root -p calvin -r $ip --nocertwarn set bios.biosbootsettings.BootMode Bios

# Create a job to enable the changes following the reboot
echo "IP: $ip - creating job for restarting"
./racadm -u root -p calvin -r $ip --nocertwarn jobqueue create NIC.Integrated.1-1-1
./racadm -u root -p calvin -r $ip --nocertwarn jobqueue create NIC.Integrated.1-2-1
./racadm -u root -p calvin -r $ip --nocertwarn jobqueue create BIOS.Setup.1-1

# Get the MAC addresses
./racadm -u root -p calvin -r $ip --nocertwarn getsysinfo | grep Ethernet

# reboot so that the configur job will execute
echo "IP: $ip - server restarting"
./racadm -u root -p calvin -r $ip --nocertwarn serveraction powercycle
