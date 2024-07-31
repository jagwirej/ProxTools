#!/bin/bash

#Get vars
. /proxtools/vars.config

node=$1
vmid=$2

# Get PID of VMID entered into the script
pid=$(ssh ${SSHUser}@${node} pgrep -o -f ".*-name.*${vmid}.*")

# Define equal weights for CPU and RAM
cpu_weight=${VMCPUWeight}
ram_weight=${VMRAMWeight}

# Initialize variables for cumulative values
total_weighted_average=0

# Run the process x times on the remote server
for ((i=1; i<=${ItCount}; i++)); do
    # Execute the script remotely for RAM usage
    process_ram=$(ssh ${SSHUser}@$node "ps -p $pid -o rss=")
    total_ram=$(ssh ${SSHUser}@$node "free -k | awk '/^Mem:/{print \$2}'")
    ram_percentage=$(ssh ${SSHUser}@$node "awk 'BEGIN {printf \"%.2f\", ($process_ram / $total_ram) * 100}'")

    # Execute the script remotely for CPU usage
    cpu_percentage=$(ssh ${SSHUser}@$node "ps -p $pid -o %cpu=")

    # Calculate weighted average
    weighted_average=$(awk "BEGIN {printf \"%.2f\", ($cpu_weight * $cpu_percentage) + ($ram_weight * $ram_percentage)}")

    # Accumulate the values for calculating the overall average
    total_weighted_average=$(echo "$total_weighted_average + $weighted_average" | bc)

    # Sleep for 1 second before the next iteration
    sleep 1
done

# Calculate the overall average
overall_average=$(awk "BEGIN {printf \"%.2f\", $total_weighted_average / 5}")

echo "$overall_average"
