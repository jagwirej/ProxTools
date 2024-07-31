#!/bin/bash

#Get vars
. /proxtools/vars.config

#Remove skipbackupvm.txt
rm skipbackupvm.txt 2>/dev/null

#Get last moved vm we are trying to migrate
vm=$(cat ${DIR}loadbalance/lastmigratedvm.txt)
#Get last low node
lownode=$(cat ${DIR}loadbalance/lastlownode.txt)
#Get last high node
highnode=$(cat ${DIR}loadbalance/lasthighnode.txt)
#This returns the vm id if it is on the low node, nothing if not
success=$(ssh ${SSHUser}@$lownode qm list | awk '{if(NR>0)print $1}' | grep $vm)
#This returns "lock: migrate" for telling us if a vm is currently locked for migrating
locked=$(ssh ${SSHUser}@$highnode qm config $vm 2>/dev/null | grep lock | grep migrate)
lockedbackup=$(ssh ${SSHUser}@$highnode qm config $vm 2>/dev/null | grep lock | grep backup)

#Debug
#echo $vm
#echo "Moving from ${highnode}"
#echo " > ${lownode}"
#echo $success
#echo $locked
#echo $lockedbackup

#We can also check if there is a "lock: migrate", which means the vm is still migrating.
#If we dont get "lock: migrate", we can assume the task completed, or failed, and move on.
if [[ "${lockedbackup}" == "lock: backup" ]]; then
        echo "Currently locked: Backup"
	cp ${DIR}loadbalance/lastmigratedvm.txt ${DIR}loadbalance/skipbackupvm.txt
        exit
elif [[ "${locked}" != "lock: migrate" ]]; then
	#This tells us that the vm is now on the "low" node
	if [ -n "$success" ]; then
		#This tells us that the vm is on the low node, job completed successfully
		echo $success
	else
		#This tells us that the vm failed to move to the low node
	        echo "$vm" > ${DIR}loadbalance/failedmovevm.txt
		echo "Failed Migrating"
	fi
	exit
else
	#If we got this far, echo NULL and exit
	echo "Currently Migrating"
	exit
fi

#If it gets here, something bad happened
echo "wat"
