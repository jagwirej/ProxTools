. /proxtools/vars.config

for server in "${Servers[@]}"; do
	for vmid in "${DailyFreezeVMIDs[@]}"; do
		ssh root@$server qm suspend $vmid
	done
done
