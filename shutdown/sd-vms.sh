#!/bin/bash

#Get vars
. /proxtools/vars.config


#Loop through hostnames
for server in "${Servers[@]}"; do
	echo "${server}"
	ssh ${SSHUser}@$server qm list | grep -v $ManagerVMID  | grep running | awk '{$1=$1;print}' | cut -d ' ' -f 1 | qm shutdown
done
