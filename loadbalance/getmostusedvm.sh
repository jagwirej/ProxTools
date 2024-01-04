#Accepts first parameter as the proxmox node
node=$1

#Reads file to see which vm was moved last
lastvm=$(cat "/proxtools/loadbalance/lastmigratedvm.txt")

#Convert string to integer
lastvm=$(($lastvm + 0))

#Get all running vms on node given as a parameter
vmstring=$(bash /proxtools/loadbalance/getvmsonnode.sh $node)

vms=($vmstring)

#Setup i as variable to iterate to determine which vm is the first in the list
i=0

#For loop to iterate through all running vms
for vm in "${vms[@]}"; do

	#Check if vm is last vm moved
	if [ $vm -eq $lastvm ]; then
		continue
	fi

	#Get CPU usage of specific VM
	usage=$(bash /proxtools/loadbalance/getvmload.sh $node $vm)

	#If this is the first iteration, assign usage to maxusage
	if [ "$i" -lt 1 ]; then
		maxvm=$vm
		maxusage=$usage
	fi

	#If current VM usage is higher than recorded maxusage, set maxusage to current usage
	if (( $(echo "$usage > $maxusage" | bc -l) )); then
		maxvm=$vm
		maxusage=$usage
	fi

	#Itterate i
	((i++))
done

if [ "$maxvm" = "" ]; then
	#Return NULL if no output for error handling
        echo "NULL"

	#Write last migrated vm to file
	echo "NULL" > "/proxtools/loadbalance/lastmigratedvm.txt"
else
        #Write last migrated vm to file
	echo "$maxvm" > "/proxtools/loadbalance/lastmigratedvm.txt"
	#Return highest used vmid
	echo $maxvm
fi
