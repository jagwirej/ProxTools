. /proxtools/vars.config

#If this boolean remains false, all nodes are balanced
balance=false

i=0

for node in "${Servers[@]}"; do

        #Assign name to variable for ease of use
        name=$node

 	 #Checks if node is in maintenance mode
        if [[ $name == ${MaintenanceMode} ]]; then
                continue
        fi

        #Get CPU usage of node
        usage=$(bash /proxtools/loadbalance/getweightedscore.sh $name)

        #Convert float point to integer for comparison
        usage=$(printf "%.0f" $usage)

        if [ $i -eq 0 ]; then

                #Sets first server as min use
                minServer=$name
                minUsage=$usage
		maxUsage=$usage
        fi

        if [ $i -gt 0 ]; then

                #Checks to see if the current usage is different than the least usage
                if [ $usage != $minUsage ]; then
                        balance=true
                fi

                #Checks to see if current usage is lower than the least usage
                if [ $usage -lt $minUsage ]; then
                        minServer=$name
                        minUsage=$usage
                fi

		#Checks to see if current usage is also the max usage
		if [ $usage -gt $maxUsage ]; then
			maxUsage=$usage
		fi

        fi

        ((i++))
done

#Find the delta between the max usage and min usage to determine if a move is necessary
usageDelta=$(($maxUsage - $minUsage))

#All server usages were equal, so return null
if [ $balance == "false" ]; then
        echo "NULL"
fi


#If delta is 5 or greater, then pass on the lowest used node
if [ $usageDelta -ge 3 ]; then

	#At least some server usages were unique, so return result
	if [ $balance == "true" ]; then
        	echo "${minServer}"
	fi
else

	#If delta is below 5, pass NULL
	echo "NULL"
fi
