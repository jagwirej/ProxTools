# Remote server details
remote_user="root"
remote_host=$1

# Function to calculate weighted score
calculate_score() {
    cpu_weight=$1
    ram_weight=$2
    cpu_score=$(echo "scale=2; $cpu_usage * $cpu_weight" | bc)
    ram_score=$(echo "scale=2; $ram_usage * $ram_weight" | bc)
    total_score=$(echo "scale=2; $cpu_score + $ram_score" | bc)
    printf "%.2f" $total_score
}

# Function to get CPU and RAM usage on the remote server
get_remote_usage() {
    cpu_usage=$($ssh_command "top -b -n 1 | grep '%Cpu' | awk '{print \$2}' | cut -d'%' -f1")
    ram_usage=$($ssh_command "free | grep Mem | awk '{print \$3/\$2 * 100.0}'")
}

# Set equal weights for CPU and RAM
cpu_weight=0.5
ram_weight=0.5

# Number of iterations
iterations=5

# Variable to store the total score
total_score=0

# Loop for 5 iterations
for ((i=1; i<=$iterations; i++)); do
    # SSH into the remote server and get CPU and memory usage
    ssh_command="ssh $remote_user@$remote_host"
    get_remote_usage

    # Calculate the weighted score for each iteration
    weighted_score=$(calculate_score $cpu_weight $ram_weight)

    # Accumulate the total score
    total_score=$(echo "scale=2; $total_score + $weighted_score" | bc)

    # Sleep for 1 second between iterations
    sleep 1
done

# Calculate and print the average score
average_score=$(echo "scale=2; $total_score / $iterations" | bc)
echo "$average_score"
