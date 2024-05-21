#!/bin/bash
#Check for vars
#Get hostname
if [ "$1" != "" ]; then
    echo "Adding key to host $1"
	sethost="$1"
else
    echo "Please provide a host to send keyfile to (do not put username)."
	exit 1
fi
#Get user to use, if none supplied then use current username
if [ "$2" != "" ]; then
    echo "Setting user to $2"
	setuser="$2"
else
    echo "Setting user to $USER"
	setuser="$USER"
fi
echo "Press enter to run."
read IGNORE
#Need to get absolute path of home directory
HOME=$(echo ~)
#Create keyfile if needed
if [ ! -f "$HOME/.ssh/id_rsa" ]; then
	ssh-keygen -t rsa -b 2048 -q -f "$HOME/.ssh/id_rsa" -N ""
fi
#Copy to host
ssh-copy-id -i "$HOME/.ssh/id_rsa.pub" "${setuser}@${sethost}"
#SSH to host to test
ssh "${setuser}@${sethost}"
