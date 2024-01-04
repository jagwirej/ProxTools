vm=$(cat /proxtools/loadbalance/lastmigratedvm.txt)
node=$(cat /proxtools/loadbalance/lasthighnode.txt)
success=$(ssh root@$node qm list | grep $vm | awk '{if(NR>0)print $1}')
if [ -n "$success" ]; then
	echo $success
else
	echo "NULL"
fi
