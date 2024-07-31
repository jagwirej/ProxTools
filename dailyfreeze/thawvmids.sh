#!/bin/bash

#Get vars
. /proxtools/vars.config

for server in "${Servers[@]}"; do
	for vmid in "${DailyFreezeVMIDs[@]}"; do
		ssh root@$server qm resume $vmid
	done
done
