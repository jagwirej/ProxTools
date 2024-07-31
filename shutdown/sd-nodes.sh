#!/bin/bash

#Get vars
. /proxtools/vars.config

#Loop through hostnames
for server in "${AllServers[@]}"; do
	ssh ${SSHUser}@$server "shutdown -h +5"
done
#Sleep
echo 'Sleeping for 5 seconds to allow connections to close...'
sleep 4
echo 'Shutting down.'
sleep 1
#Shutting down management VM
ssh ${SSHUser}@$SERVERS "qm shutdown $ManagerVMID"
