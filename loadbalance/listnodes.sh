#Declare nodelist as an array
declare -a nodelist

#Type in your actual node names here
nodelist=("node1" "node2" "node3" "node4")

#List out each node in its own line for other scripts to use
for value in "${nodelist[@]}"; do
	echo $value
done
