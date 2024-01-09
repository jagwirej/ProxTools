server=$1
ssh root@$server qm list | grep running | awk '{$1=$1;print}' | cut -d ' ' -f 1
#ssh root@$server qm list | grep running
