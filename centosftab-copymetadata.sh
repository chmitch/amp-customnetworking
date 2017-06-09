#!/bin/bash

deploymentName=$1
region=$2
vnet=$3
cdir=$4
subnet=$5
subscription=$6
storagename=$7

# Set value to be used for filesystem mount point folder
# this will be the first param passed into the script execution
mp=$8

# masterIP
masterIP=$9 

# write content to file in /etc/metadata

printf '{"deploymentName":"%s", "region":"%s","vnet":"%s","cdir":"%s","subnet":"%s","subscription":"%s","storagename":"%s"}\n' "$deploymentName" "$region" "$vnet" "$cdir" "$subnet" "$subscription" "$storagename" >> /etc/orca-master.json

# begin mounting disk

# Set bash script options
set -o nounset
set -o errexit

echo 'before yum' >> /etc/1.txt

# Install mdadm on Centos
sudo yum -y -q install mdadm

echo 'after yum' >> /etc/2.txt

# Create backup copy of fstab
sudo cp /etc/fstab /etc/fstab.orig

echo 'after backup fstab ' >> /etc/3.txt

# Enumerate data disks attached to VM 
# Leverages udev rules for Azure storage devices located at https://github.com/Azure/WALinuxAgent/blob/2.0/config/66-azure-storage.rules
attached=`basename -a $(find /sys/class/block -name 'sd[a-z]')`
reserved=`basename -a $(readlink -f /dev/disk/azure/root /dev/disk/azure/resource)`
datadisks=(${attached[@]/$reserved})

echo 'after attaching disks' >> /etc/4.txt 

# Set value to be used for filesystem label - max length 16 chars
fslabel=$(hostname | cut -c1-10)-$mp

echo 'after fslabel' >> /etc/5.txt

# Set value for filesystem barriers - 0 if using Premium Storage w/ ReadOnly Caching or NoCache; 1 otherwise
b=0

# Set value for initial RAID command string used to span multiple data disks
RAID_CMD="mdadm --create /dev/md1 --level 0 --raid-devices ${#datadisks[@]} "

echo 'after set initial raid cmd' >> /etc/6.txt

# Loop through each data disk, fdisk and add to RAID command string
for d in "${datadisks[@]}"; do
    disk="/dev/${d}"
    (echo n; echo p; echo 1; echo ; echo ; echo t; echo fd; echo p; echo w;) | fdisk ${disk}
    RAID_CMD+="${disk}1 "
done

echo 'after looping data disks' >> /etc/7.txt

RAID_CMD+=" --force"

echo 'after --force' >> etc/8.txt

# Build RAID device
eval "$RAID_CMD"

echo 'after eval raid_cmd' >> /etc/8.txt

# Format and label filesystem
mkfs.ext4 /dev/md1 -L ${fslabel}

echo 'after mkfs.ext4' >> /etc/9.txt

# Set value of UUID for new filesystem
uuid=$(blkid -p /dev/md1 | grep -oP '[-a-z0-9]{36}')

echo 'after setting UUID for fs' >> /etc/10.txt

# Create mount point folder
mkdir -p /media/${mp}

echo 'after mkdir media' >> /etc/11.txt

# Add new filesystem to working copy of fstab
echo "UUID=${uuid} /media/${mp} ext4 defaults,noatime,barrier=${b} 0 0" >> /etc/fstab

echo 'after add fs to fstab' >> /etc/12.txt

# Mount all unmounted filesystems
mount -a

echo 'after mounting fs' >> /etc/13.txt

# After initial provisioning, use these commands to obtain disk device or UUID of filesystem based on label
# disk=$(blkid -L ${fslabel})
# uuid=$(blkid | grep "LABEL=\"${fslabel}\"" | grep -oP '[-a-z0-9]{36}')


# Cloud Init Data - no ifdown no ifup 

# echo '[[1, "$masterIP"], [2, "10.0.3.253"], [3, "10.0.3.254"]]' > /etc/orchestrators;
# touch /etc/wait_to_start_orchestrator;
# yum install -y --disablerepo=* --enablerepo=foundation mpmgr;
# python /opt/tetration/mpmgr/mount_point_manager.py;
# yum install -y --disablerepo=* --enablerepo=foundation consul orchestrator vault ui-setup rpminstall terraform azmgr;# cp /etc/yum.local.repos.d/local.repo /etc/yum.repos.d;
# sed -i /BOOTPROTO/d /etc/sysconfig/network-scripts/ifcfg-eth0;
# sed -i -e s/^BOOTPROTO.*/BOOTPROTO=static/ /etc/sysconfig/network-scripts/ifcfg-eth0;
# sed -i -e s/^IPADDR.*// /etc/sysconfig/network-scripts/ifcfg-eth0;
# sed -i -e s/^NETMASK.*// /etc/sysconfig/network-scripts/ifcfg-eth0;
# sed -i -e s/^GATEWAY.*// /etc/sysconfig/network-scripts/ifcfg-eth0;
# echo IPADDR=10.0.3.252 >> /etc/sysconfig/network-scripts/ifcfg-eth0;
# echo NETMASK=255.255.0.0 >> /etc/sysconfig/network-scripts/ifcfg-eth0;
# ifdown eth0;
# ifup eth0;
# echo '[]' >> /etc/secrets;
# chown root:root /etc/secrets;
# chmod 600 /etc/secrets;
#     echo -e "private-1: ifname: eth0 public: ifname: eth1 " > /etc/active_ifs.yml
