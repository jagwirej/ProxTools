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

4. Schedule a cronjob to run /proxtools/loadbalance/loadbalancenodes.sh at whatever interval you like (my recommendation would be every 15 minutes).


--------------------
Special Thanks:


@inthebrilliantblue

  For answering all my crazy Linux based questions and solving the OS error messages that came up along the way.
  
  https://github.com/inthebrilliantblue



The man who shall be known as "Oldmanwithacigarette"

  This was more or less his brainchild. Not so much the idea of load balancing, but definitely
  
  the idea of how to implement the project by using a dedicated management machine.
