#Get list of nodes from listnodes.sh
nodes=($(bash listnodes.sh))

#If this boolean remains false, all nodes are balanced
balance=false

i=0

for node in "${nodes[@]}"; do

        #Assign name to variable for ease of use
        name=$node

        #Get CPU usage of node
        usage=$(ssh root@$name mpstat 1 1 | awk 'NR>3 && $12 ~ /[0-9.]+/ { print 100 - $13; exit }')

        #Convert float point to integer for comparison
        usage=$(printf "%.0f" $usage)

        if [ $i -eq 0 ]; then

                #Sets first server as highest use
                maxServer=$name
                maxUsage=$usage
        fi

        if [ $i -gt 0 ]; then

                #Checks to see if the current usage is different than the least usage
                if [ $usage != $maxUsage ]; then
                        balance=true
                fi

                #Checks to see if current usage is lower than the least usage
                if [ $usage -gt $maxUsage ]; then
                        maxServer=$name
                        maxUsage=$usage
                fi

        fi

        ((i++))
done


#At least some server usages were unique, so return result
if [ $balance == "true" ]; then
        echo "${maxServer}"
fi


#All server usages were equal, so return null
if [ $balance == "false" ]; then
        echo "NULL"
fi
