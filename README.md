# ProxTools
Scripts written for an Ubuntu VM or dedicated machine to manage a clustered ProxMox installation.
The biggest requested feature being a Load Balancer to balance the CPU load across a clustered ProxMox environment.

----------

Setup Instructions:

1. Have a dedicated VM or machine running Ubuntu.
     - This machine can run inside of the ProxMox cluster or on its own dedicated hardware.
     - For some features, it is recommended that this be on dedicated hardware not hosted on your ProxMox cluster.

2. Setup passwordless SSH between this machine/vm and each individual node in your cluster that will be running VMs.

3. Copy these scripts into /proxtools on the management machine/vm so all filepaths will work correctly.

4. Update the vars.config file.
	- Fill out ManagerVMID if your dedicated machine is running on the ProxMox Cluster (for shutdown tools).
	- Fill out OtherServers if you have any nodes that do not run VMs, but need to be shutdown in bulk.
	- Fill out Servers with a list of any nodes that run VMs.
 	- Fill out EmailFrom with the from address for email alerts
  	- Fill out EmailRecipients with any email addresses you would like alerts sent to 

5. Install mpstat on each of your ProxMox nodes (to measure cpu usage).

6. Install and configure ssmtp on the management machine/vm and configure /etc/ssmtp/ssmtp.conf accordingly for your environment

7. Schedule a cronjob to run /proxtools/loadbalance/loadbalancenodes.sh at whatever interval you like (my recommendation would be every 15 minutes).

----------
How the Load Balancer Works:

Without digging too much into the weeds of it all, the loadbalancenodes script calls other scripts to make a couple determinations:

**Scoring system has now changed to equally weigh CPU and RAM usage when determining the highest/lowest used node and vm**

1. It calls getmostusednode.sh to determine which node in your cluster has the highest score (both RAM and CPU usage equally weighed)
2. It calls getleastusednode.sh to determine which node in your cluster has the lowest score (both RAM and CPU usage equally weighed)
3. If the difference in score between the highest and lowest used node is lower than 5%, it will exit the script
4. It then calls getmostusedvm.sh to determine which VM has the highest score (both RAM and CPU usage equally weighed)
5. It checks to see if the last migration request has completed. Will exit script if not
6. Finally, it migrates the highest used VM from the highest used node to the lowest used node

--------------------
Special Thanks:

Sid3b00m

For getting the ball rolling with ProxMox. This project would have never begun if you hadn't hounded me to build a cluster. :D


@inthebrilliantblue

  For answering all my crazy Linux based questions and solving the OS error messages that came up along the way.
  
  https://github.com/inthebrilliantblue



The man who shall be known as "Oldmanwithacigarette"

  This was more or less his brainchild. Not so much the idea of load balancing, but definitely
  
  the idea of how to implement the project by using a dedicated management machine.
