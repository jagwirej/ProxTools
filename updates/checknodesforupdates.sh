#!/bin/bash

#Get vars
. /proxtools/vars.config

emailbody="The following nodes have pending updates:\n\n"

for node in "${AllServers[@]}"; do
	#echo "Node:" $node

	Updates=$(ssh ${SSHUser}@$node 'apt-get update -qq && apt list --upgradable 2>/dev/null | grep -v "Listing..."')
	UpdateCount=$(echo -e "$Updates" | wc -l)
	ActualCount=$(($UpdateCount - 1))
	if [ $ActualCount -gt 0 ]; then
		updates=$"TRUE"
		emailbody="$emailbody\n$node"
	fi
done

if [ $updates = "TRUE" ];then
	echo -e  "From: ${EmailFrom}\nTo: ${EmailRecipients}\nSubject: ProxManager Alerts\n\n${emailbody}" | ssmtp ${EmailRecipients}
fi
