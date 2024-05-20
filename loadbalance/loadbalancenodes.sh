#!/bin/bash

#Echos out timestamp for logging
date

#Get vars
. /proxtools/vars.config

#Set DIR for this script
SDIR="${DIR}loadbalance"

#Get other values
lastmove=$(bash /proxtools/loadbalance/checkformovedvm.sh)
lasthighvm=$(cat /proxtools/loadbalance/lastmigratedvm.txt)
lastlownode=$(cat /proxtools/loadbalance/lastlownode.txt)
lasthighnode=$(cat /proxtools/loadbalance/lasthighnode.txt)

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
        $SDIR/emailalert.sh "CurrentMigration" "$lastmove" "$lastlownode" "ProxManager Alert"

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
        $SDIR/emailalert.sh "FailedToMigrate" "$lastmove" "$lastlownode" "ProxManager Alert"
fi


#Get current high usage node
highnode=$(bash /proxtools/loadbalance/getmostusednode.sh)
if [ "$highnode" = "NULL" ]; then
        echo "No highnode found, exiting script"
        echo
        exit
fi
#Get current low usage node
lownode=$(bash /proxtools/loadbalance/getleastusednode.sh)
if [ "$lownode" = "NULL" ]; then
        echo "No lownode found, exiting script"
        echo
        exit
fi
#Debug
echo "High Node: ${highnode}"
echo "Low Node: ${lownode}"
echo
echo $lownode > "/proxtools/loadbalance/lastlownode.txt"
echo $highnode > "/proxtools/loadbalance/lasthighnode.txt"
highvm=$(bash /proxtools/loadbalance/getmostusedvm.sh $highnode)
echo "High VM: ${highvm}"
echo
ssh root@$highnode qm migrate $highvm $lownode --online
