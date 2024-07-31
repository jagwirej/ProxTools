#!/bin/bash

#Get vars
. /proxtools/vars.config

#Sets the ssh user
remote_user="root"

#Default when no node is in maintenance mode
configname='MaintenanceMode=""'

#Set DIR for this script
SDIR="${DIR}maintenancemode"

#Prompts the user to select the maintenance node
PS3="Please enter which node you would like to put in maintenance mode: "

select opt in "${Servers[@]}"
do
	if [[ "$opt" == "Quit" ]]; then
		break
	elif [[ " ${Servers[*]} " == *" $opt "* ]]; then
		echo "You chose $opt"
		break
	else
		echo "Invalid option $REPLY"
	fi
done

#Sets the output of the selection to node variable
node=$opt

#MaintenanceMode variable with desired node
maintnode="MaintenanceMode=\"$node\""

#If MaintenanceMode is null, then get list of running VMs on node. If MaintenanceMode is not null, prompt to unset maintenance mode.
if [ -z ${MaintenanceMode} ]; then
	#Gets a list of running vms on node
	vmstring=$(bash ${DIR}list/getvmsonnode.sh $node)
	vms=($vmstring)
else
	echo "${MaintenanceMode} is currently in maintenance mode."
	while true; do
		read -p "Would you like to take it out of maintenance mode? (y/n): " yn
		case $yn in
			[Yy]* ) echo "You chose yes. Un-setting maintenance mode on ${MaintenanceMode}."
			./unsetmaintenancemode.sh
			#Gets a list of running vms on node
		        vmstring=$(bash ${DIR}list/getvmsonnode.sh $node)
        		vms=($vmstring)
			break;;
			[Nn]* ) echo "You chose no. Exiting script."; exit;;
			* ) echo "Please answer yes or no.";;
		esac
	done
fi

#Replaces the blank space in vars.config with the intended node name
sed -i "s/${configname}/${maintnode}/g" ${DIR}vars.config
echo "Maintenance Mode Set"

#Get the index of the next server
        NextIndex=$(echo "${Servers[@]}" | tr ' ' '\n' | grep -n "^$node$" | cut -d: -f1)

#Get the index of the current maintenance server
        MaintIndex=$(($NextIndex - 1))

echo "Migrating VMs off of ${node}."
#Loops through all running VMs on node to migrate them off
for vm in "${vms[@]}"; do
	movenode=$(bash ${DIR}loadbalance/getleastusednode.sh)
	if [ $movenode == "NULL" ]; then
		if [ $NextIndex == $MaintIndex ]; then
		NextIndex=$(($NextIndex + 1))
		fi
        	# Check if the next index is within bounds
		if [ $NextIndex -lt ${#Servers[@]} ]; then
			movenode=${Servers[$NextIndex]}
		else
			if [ $MaintIndex == 0  ]; then
				movenode=${Servers[1]}
			else
				movenode=${Servers[0]}
			fi
		fi
	fi
	#Migrates VM to lowest used node
	ssh $remote_user@$node qm migrate $vm $movenode --online
done
