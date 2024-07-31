#!/bin/bash

#Echos out timestamp for logging
date

#Get vars
. /proxtools/vars.config

#Set DIR for this script
SDIR="${DIR}loadbalance"

#Get other values
lastmove=$(bash $SDIR/checkformovedvm.sh)
lasthighvm=$(cat $SDIR/lastmigratedvm.txt)
lastlownode=$(cat $SDIR/lastlownode.txt)
lasthighnode=$(cat $SDIR/lasthighnode.txt)

#Debug
echo "Last moved VM: ${lasthighvm}"
echo "Last high node: ${lasthighnode}"
echo "Last low node: ${lastlownode}"
echo "Checking for moved VM: ${lastmove}"


#Check if the last move has completed that migration.
if [[ "$lastmove" == "Currently Migrating" ]]; then
	echo "Last node has not finished migrating, or an error has occurred."
	echo
	echo "Last Low Node: $lastlownode"
	echo "Last High VM: $lasthighvm"
	echo
	$SDIR/emailalert.sh "CurrentMigration" "$lasthighvm" "$lastlownode" "ProxManager Alert"

	if [ "$lasthighvm" = "NULL" ] || [ "$lastlownode" = "NULL" ] || [ "$lastlownode" = "NULL NULL" ]; then
		echo "Either lasthighvm or lastlownode is NULL, continuing."
		echo
	else
		exit
	fi
elif [[ "$lastmove" == "$lasthighvm" ]]; then
	#Successfully moved
	echo "Successfully moved"
elif [[ "$lastmove" == "Currently locked: Backup" ]]; then
	#VM is locked for backing up
	echo "${lasthighvm} is currently being backed up"
	$SDIR/emailalert.sh "Backup" "$lasthighvm" "$lastlownode" "ProxManager Alert"
else
	#Failed to migrate
	echo "Failed to migrate"
	$SDIR/emailalert.sh "FailedToMigrate" "$lasthighvm" "$lastlownode" "ProxManager Alert"
fi

#Get current high usage node
highnode=$(bash $SDIR/getmostusednode.sh)
if [ "$highnode" = "NULL" ]; then
	echo "No highnode found, exiting script"
	echo
	exit
fi
#Get current low usage node
lownode=$(bash $SDIR/getleastusednode.sh)
if [ "$lownode" = "NULL" ]; then
	echo "No lownode found, exiting script"
	echo
	exit
fi
#Debug
echo "High Node: ${highnode}"
echo "Low Node: ${lownode}"
echo
echo $lownode > "$SDIR/lastlownode.txt"
echo $highnode > "$SDIR/lasthighnode.txt"
highvm=$(bash $SDIR/getmostusedvm.sh $highnode)
echo "High VM: ${highvm}"
echo
ssh ${SSHUser}@$highnode qm migrate $highvm $lownode --online
