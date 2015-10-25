#!/bin/bash

#Just call the script and pass in the parameters when asked.

function Build-VMs ()
{
  read -p "What Type of OS will you install?: " ostype

  read -p "How many hosts do you want to setup?: " hosts

  read -p "How many SAS drives do you want for each host?: " sasdrives

  if [ $hosts -lt 1 ]; then
  echo "Please enter a number of hosts greater than 0"
  exit
  fi

  counter=0
  sascounter=0

  while [ $counter -lt $hosts ]; do

    VBoxManage createvm --name "StorageHost_$counter"  --register
    VBoxManage modifyvm "StorageHost_$counter" --ostype $ostype

    VBoxManage modifyvm "StorageHost_$counter" --memory 4096
    VBoxManage modifyvm "StorageHost_$counter" --cpus 2
    VBoxManage modifyvm "StorageHost_$counter" --ioapic on

    VBoxManage storagectl "StorageHost_$counter" --name IDE --add ide --controller PIIX4 --bootable on
    VBoxManage storagectl "StorageHost_$counter" --name SATA --add sata --controller IntelAhci --bootable on
    VBoxManage storagectl "StorageHost_$counter" --name SAS --add sas --controller LSILogicSAS
    
    VBoxManage createhd --filename "Boot_StorageHost_$counter.vdi" --size 32768

    VBoxManage storageattach "StorageHost_$counter" --storagectl IDE --port 0 --device 0 --type dvddrive --medium emptydrive
    VBoxManage storageattach "StorageHost_$counter" --storagectl SATA --port 0 --device 0 --type hdd --medium Boot_StorageHost_$counter.vdi

    while [ $sascounter -lt $sasdrives ]; do
    VBoxManage createhd --filename "SAS$sascounter StorageHost_$counter.vdi"  --size 131072
    VBoxManage storageattach "StorageHost_$counter" --storagectl SAS --port $sascounter --device 0 --type hdd --medium "SAS$sascounter StorageHost_$counter.vdi"

    sascounter=$[$sascounter +1]
    done

    VBoxManage modifyvm "StorageHost_$counter" --nic1 nat --nictype1 82540EM --cableconnected1 on
    VBoxManage modifyvm "StorageHost_$counter" --nic2 bridged --nictype1 82540EM --cableconnected1 on

    counter=$[$counter +1]
    sascounter=0 #Need to reset sascounter to zero before $sascounter hits 3.
  done
}

Build-VMs