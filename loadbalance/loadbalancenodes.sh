lastmove=$(bash /proxtools/loadbalance/checkformovedvm.sh)
lasthighvm=$(cat /proxtools/loadbalance/lastmigratedvm.txt)
lastlownode=$(cat /proxtools/loadbalance/lastlownode.txt)
if [ $lastmove = "NULL" ]; then
	echo "Last node has not finished migrating, or an error has occurred."
	echo	
	echo "Last Low Node: $lastlownode"
	echo "Last High VM: $lasthighvm"
	echo
	echo -e  "Last node has not finished migrating, or an error has occurred.\nLast Low Node: $lastlownode.\nLast High VM: $lasthighvm.\n" > "/proxtools/loadbalance/log.txt"
	if [ "$lasthighvm" = "NULL" ] || [ "$lastlownode" = "NULL" ] || [ "$lastlownode" = "NULL NULL" ]; then
		echo "Either lasthighvm or lastlownode is NULL, continuing."
		echo
	else
		exit
	fi
fi
highnode=$(bash /proxtools/loadbalance/getmostusednode.sh)
if [ "$highnode" = "NULL" ]; then
	echo "No highnode found, exiting script"
	echo
	exit
fi
lownode=$(bash /proxtools/loadbalance/getleastusednode.sh)
if [ "$lownode" = "NULL" ]; then
	echo "No lownode found, exiting script"
	echo
	exit
fi
echo "High Node: ${highnode}"
echo "Low Node: ${lownode}"
echo
echo $lownode > "/proxtools/loadbalance/lastlownode.txt"
highvm=$(bash /proxtools/loadbalance/getmostusedvm.sh $highnode)
echo "High VM: ${highvm}"
echo
ssh root@$highnode qm migrate $highvm $lownode --online
