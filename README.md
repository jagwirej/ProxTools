# ProxTools
Scripts written for an Ubuntu VM or dedicated machine to manage a clustered ProxMox installation.
The biggest requested feature being a Load Balancer to balance the CPU load across a clustered ProxMox environment.

----------

Setup Instructions:

1. Have a dedicated VM or machine running Ubuntu.
     This machine can run inside of the ProxMox cluster or on its own dedicated hardware.
     For some features, it is recommended that this be on dedicated hardware not hosted on your ProxMox cluster.

2. Setup passwordless SSH between this machine/vm and each individual node in your cluster that will be running VMs.

3. Copy these scripts into /proxtools on the management machine/vm so all filepaths will work correctly.

4. Update the "nodelist" array in listnodes.sh to match the hostnames of your ProxMox nodes.

5. Install mpstat on each of your ProxMox nodes (to measure cpu usage).

6. Schedule a cronjob to run /proxtools/loadbalance/loadbalancenodes.sh at whatever interval you like (my recommendation would be every 15 minutes).

----------
How the Load Balancer Works:

Without digging too much into the weeds of it all, the loadbalancenodes script calls other scripts to make a couple determinations:

1. It calls getmostusednode.sh to determine which node in your cluster has the highest percentage of CPU usage
2. It calls getleastusednode.sh to determine which node in your cluster has the lowest percentage of CPU usage
3. If the difference in percentage between the highest and lowest used node is lower than 5%, it will exit the script
4. It then calls getmostusedvm.sh to determine which VM has the highest percentage of CPU usage
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
