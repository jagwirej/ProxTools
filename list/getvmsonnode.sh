#!/bin/bash

#Get vars
. /proxtools/vars.config

server=$1

ssh ${SSHUser}@${server} qm list | grep running | awk '{if(NR>0)print $1}'
