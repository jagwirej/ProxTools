highnode=$(bash /proxtools/loadbalance/getmostusednode.sh)
lownode=$(bash /proxtools/loadbalance/getleastusednode.sh)
echo "High Node: ${highnode}"
echo "Low Node: ${lownode}"
highvm=$(bash /proxtools/loadbalance/getmostusedvm.sh $highnode)
echo "High VM: ${highvm}"

ssh root@$highnode qm migrate $highvm $lownode --online
