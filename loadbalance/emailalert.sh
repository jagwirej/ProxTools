#!/bin/bash

#Get vars
. /proxtools/vars.config

status=$1
vmid=$2
cnode=$3
emailsubject=$4

#If the status is Current Migration, set email body
if [ "$status" == "CurrentMigration" ];then
        emailbody=$"${vmid} failed to migrate to ${cnode}\nThe previous migration request is still processing."
fi

#If the status is Backup, set email body
if [ "$status" == "Backup" ];then
        emailbody=$"${vmid} failed to migrate to ${cnode}\nThere is a current backup job"
fi

#If the status is FailedToMigrate, set email body
if [ "$status" == "FailedToMigrate" ];then
        emailbody=$"${vmid} failed to migrate to ${cnode}"
fi


FileLoc=$"/proxtools/loadbalance/lastemailstats.txt"
#If there is an existing lastemailstats.txt file
if [ -e "$FileLoc" ]; then
        lastvmid=$(head "$FileLoc")
        laststatus=$(sed -n '2p' "$FileLoc")
        lastemailcount=$(tail -n 1 "$FileLoc")
#If there is no existing lastemailstats.txt file
else
        lastvmid=$"000"
        laststatus=$"NULL"
        lastemailcount="0"
fi

#If the last status is the same as the current status
if [ $laststatus == $status ]; then
        lastcount=$(expr $lastemailcount + 0)
        newemailcount=$(expr $lastcount + 1)
else
        lastcount=0
        newemailcount=1
fi


#Writing results to lastemailstats.txt
echo -e "${vmid}\n${status}\n${newemailcount}" > /proxtools/loadbalance/lastemailstats.txt


#If the last count is less than or equal to one
if [ $lastcount -le 1 ]; then
        echo -e  "From: ${EmailFrom}\nTo: ${EmailRecipients}\nSubject: ${emailsubject}\n\n${emailbody}" | ssmtp ${EmailRecipients}

fi

#If the last count is equal to two, this is the last email
if [ $lastcount = 2 ]; then
        echo -e  "From: ${EmailFrom}\nTo: ${EmailRecipients}\nSubject: ${emailsubject}\n\n${emailbody}\nThis is the third and final email alert for this error." | ssmtp ${EmailRecipients}

fi
