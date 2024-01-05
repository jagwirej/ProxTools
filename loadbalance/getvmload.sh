node=$1
vmid=$2

# Get PID of VMID entered into the script
pid=$(ssh root@${node} pgrep -o -f ".*-name.*${vmid}.*")

# Define equal weights for CPU and RAM
cpu_weight=0.5
ram_weight=0.5

# Initialize variables for cumulative values
total_weighted_average=0

# Run the process 5 times on the remote server
for ((i=1; i<=5; i++)); do
    # Execute the script remotely for RAM usage
    process_ram=$(ssh root@$node "ps -p $pid -o rss=")
    total_ram=$(ssh root@$node "free -k | awk '/^Mem:/{print \$2}'")
    ram_percentage=$(ssh root@$node "awk 'BEGIN {printf \"%.2f\", ($process_ram / $total_ram) * 100}'")

    # Execute the script remotely for CPU usage
    cpu_percentage=$(ssh root@$node "ps -p $pid -o %cpu=")

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
