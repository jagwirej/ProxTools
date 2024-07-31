#!/bin/bash

#Get vars
. /proxtools/vars.config

#Notice
printf "This script attempts to shutdown all VMs (except for the management VM) for a full cluster shutdown.\n"
#Shutdown VMs
printf "Shutdown all VMs (y/n)? "
read answer
#Check answer
if [ "$answer" != "${answer#[Yy]}" ] ;then
	bash "$DIR"shutdown/sd-vms.sh
else
	exit 0
fi
#Pause execution, ask if they are ready to shutdown cluster
printf "Shutdown command sent to all VMs (except management). Please monitor VMs and shutdown any VMs that do not turn off.\n"
printf "Press c when cluster is ready to shutdown. Any other key will exit script. "
read answer
#Check answer
if [ "$answer" != "${answer#[Cc]}" ] ;then
	bash "$DIR"shutdown/sd-nodes.sh
else
	exit 0
fi
