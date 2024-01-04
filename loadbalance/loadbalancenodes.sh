lastmove=$(bash /proxtools/loadbalance/checkformovedvm.sh)
lasthighvm=$(cat /proxtools/loadbalance/lastmigratedvm.txt)
lasthighnode=$(cat /proxtools/loadbalance/lasthighnode.txt)
if [ $lastmove = "NULL" ]; then
	echo "Last node has not finished migrating, or an error has occurred."
	echo	
	echo "Last High Node: $lasthighnode"
	echo "Last High VM: $lasthighvm"
	echo -e  "Last node has not finished migrating, or an error has occurred.\nLast High Node: $lasthighnode.\nLast High VM: $lasthighvm.\n" > "/proxtools/loadbalance/log.txt"
	exit
fi
highnode=$(bash /proxtools/loadbalance/getmostusednode.sh)
lownode=$(bash /proxtools/loadbalance/getleastusednode.sh)
echo "High Node: ${highnode}"
echo "Low Node: ${lownode}"
echo $highnode > "/proxtools/loadbalance/lasthighnode.txt"
highvm=$(bash /proxtools/loadbalance/getmostusedvm.sh $highnode)
echo "High VM: ${highvm}"
ssh root@$highnode qm migrate $highvm $lownode --online
