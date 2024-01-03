node=$1
vmid=$2

#Get PID of VMID entered into script
pid=$(ssh root@${node} pgrep -o -f ".*-name.*${vmid}.*")

#Get CPU Usage of PID on Node
ssh root@${node} pidstat -p $pid 1 10 | awk 'NR>7 { sum += $9 } END { if (NR > 0) print sum / NR }'
