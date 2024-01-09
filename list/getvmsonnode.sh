input=$1

#ssh root@${input} qm list | grep running | awk '{if(NR>1)print $1}'
ssh root@${input} qm list | grep running | awk '{if(NR>0)print $1}'
