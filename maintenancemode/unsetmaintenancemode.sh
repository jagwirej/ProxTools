#!/bin/bash

#Get vars
. /proxtools/vars.config

#Gets the currently set node in maintenance mode
maintnode=$(grep "MaintenanceMode=" ${DIR}vars.config)

#Default variable for when no node is in maintenance mode
defaultconfig='MaintenanceMode=""'

#Replaces the set maintenance mode variable with a blank 
sed -i "s/${maintnode}/${defaultconfig}/g" ${DIR}vars.config
