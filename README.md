# Slicing with O-RAN on Powder Testbed for Disaster Recovery

It will take about 60-120 minutes to run this experiment.

To run this experiment, you will need an account on the [POWDER testbed](https://powderwireless.net/). (If you have used CloudLab, you may already have a POWDER account!) You will also need to be part of an active project and have SSH keys associated with your account.

## 1.0 Background

Natural disasters like hurricanes or earthquakes often destroy crucial components of the cellular wireless network infrastructure. As a result, all the user equipments (hereafter referred to as UEs) in the affected region cannot connect to the core network. However, sustained cellular connectivity is crucial, especially during a natural disaster as it is used for disseminating important information and alerts to the citizens stuck and for communicating to and by the rescue workers.

For these utilities, resource sharing among network providers can be an effective solution for mitigating impact of the natural disaster. That is if the network infrastructure of a particular provider is affected by the disaster but that of another provider is working fine, then the UEs of the former provider and the UEs of rescue workers can be accommodated on the latter provider's network temporarily to mitigate impact. 

But before opening their networks to non-subscribers, providers are concerned that their own UEs would face either poorer performance or reduced connectivity as the infrastructure can be overwhelmed by the additional non-subscribing users. Hence, it is only natural for the service providers to seek reassurance that their own subscribers will not be unduly affected, if the network resources are shared with other affected providers' UEs and the rescue workers.

For this purpose, slicing may be a useful technique. Slicing allows a network administrator to define multiple virtual networks on the same physical networks. Each of these virtual networks can be optimized for the user equipments deployed on these slices. 

Hence, in this experiment, we emulate a disaster recovery scenario on POWDER testbed. This is done using network slicing in O-RAN. This should serve as a proof of concept for network sharing in disaster recovery and to support further research in the area.

### 1.1 Emulating a cellular network on POWDER

To emulate a cellular network on POWDER, we initialize an experiment using the O-RAN Profile on POWDER. The [profile](https://www.powderwireless.net/show-profile.php?project=PowderProfiles&profile=O-RAN) deploys an O-RAN instance to connect to RAN resources. It uses a fork of srsLTE (and O-RAN Software Community's RIC). [srsLTE](https://www.srslte.com/) is a free and open-source software suite (developed by Software Radio Systems) that includes: srsUE (User Equipmemt implementation), srsENB (LTE eNodeB implementation), srsEPC (LTE core network implementation) and common libraries for other layers. It has been modified to include O-RAN RIC, E2 support and RAN slicing support in the srsENB. The forked modified source code for srsRAN can be found [here](https://gitlab.flux.utah.edu/powderrenewpublic/srslte-ric).

By default, the profile runs experiments in simulated RAN mode i.e. using emulated links. However, you can also use the profile for live over-the-air testing by making a frequency reservation, initializing one or more experiments containing RAN resources and connecting them to the O-RAN experiment. [This profile](https://www.powderwireless.net/show-profile.php?profile=1bd95656-5b60-11eb-b1eb-e4434b2381fc) is configured to connect to O-RAN experiments - follow the instructions given in the profile for over-the-air testing. But for our experiment's purposes emulated links work just as well and so we will be running only the O-RAN experiment. 

The experiment initializes a single node on the POWDER testbed and we run the eNodeB, core network (EPC) and all the UEs on the same remote hardware. 

### 1.2 Network slicing with O-RAN on POWDER

For implementation of slicing with O-RAN, we use NexRAN[^1], a top-to-bottom open-source Open-RAN based slicing implementation. The souce code is published [here](https://gitlab.flux.utah.edu/powderrenewpublic/nexran). Briefly, slicing on Open RAN is realised via three major components:

[^1]: David Johnson, Dustin Maas, and Jacobus Van Der Merwe. 2021. NexRAN: Closed-loop RAN slicing in POWDER -A top-to-bottom open-source open-RAN use case. In Proceedings of the 15th ACM Workshop on Wireless Network Testbeds, Experimental evaluation & CHaracterization (WiNTECH'21). Association for Computing Machinery, New York, NY, USA, 17–23. [https://doi.org/10.1145/3477086.3480842](https://doi.org/10.1145/3477086.3480842)

1. Slice-Aware scheduler: inserted in the eNodeB that implements a subframe-based allocation of PRBs (Physical Resource Blocks)
2. NexRAN xApp: onboarded and deployed on the Near-RT RIC. It provides RESTful APIs to (a) create new UE, NodeB and slice objects; (b) bind or unbind a slice to a NodeB; (c) bind or unbind a UE to a slice; and (d) update any slice's policy.
3. E2 Agent: receives E2AP messages from the xApp (corresponding to the API invoked) and sends relevant commands to the components of the eNodeB.

To understand how the scheduling actually works, it might be a good idea to read the paper referenced above. However, I will provider here a brief summary of how the slice-aware scheduler allocates PRBs in each subframe:
1. Each subframe gives priority to a single slice.
2. Except a periodical special subframe (denoted by X) which is added to ensure that yet-to-be identified UEs (i.e. UEs that don't have a UE object corresponding to them defined in the xApp) can also connect to the network.
3. Slices are scheduled in a round-robin fashion, according to their allocation share. For example, if we have two slices A and B with resource share ratio as 2:1, then we'll have one B subframe followed by two A subframe followed by one B subframe and so on, interspersed by the periodical special subframe.
4. Within each subframe, the UEs are allocated PRBs in a round-robin fashion according to the following priority order: UEs belonging to priority slice > UEs belonging to other slices > UEs not associated with any slice
5. However, the periodical special subframe (X) follows a different priority order which is as follows: Unidentified UEs > UEs belonging to slices > UEs not associated with any slice
6. The scheduler is work-conserving by default i.e. it follows the priority order as per rules 4 and 5 above. However, the work-conserving mode can be disabled. If disabled, then in any subframe, only the UEs having the first priority in that subframe will be allotted PRBs and even if the first priority UEs do not use all the resources, those resources are not made available to other UEs. 

<div align="center">
  <img width="508" alt="image" src="https://github.com/abhimanyusethia12/oran_slicing/assets/51320930/74cc4393-de3c-42c6-96fd-70e1b945e368">
</div>

### 1.3 Disaster recovery scenario

In this experiment, we imagine a scenario with four families subscribed to the same cellular network, chosen so as to exhuastively represent the various commonly used user applications on wireless cellular network:
1. Family 1 (One single individual): Working on a Zoom call while browsing the web simultaneously
2. Family 2 (Parents with two kindergarden children): Kids on Youtube while parents browsing Reddit simultaneously
3. Family 3 (Elderly couple): Watching news
4. Family 4 (Parent working at home with teenager child): Teenager on Netflix while parent on Zoom call simultaneously

For simplicity, we represent these four families i.e. subscribers of the network provider by a single UE running 4 applications simultaneously: video-on-demand (Netflix, Youtube), video streaming (News), video calling (Zoom calls) and Web browsing (Reddit, Social Media). When a disaster, say a hurricane, strikes assume that the cellular service provider that these users are subscribed to is still operational. Hence, in all our experiments, we consider these our 'primary users' and we want to evaluate the extent to which they are affected when other non-subscrbing users are accommodated.

In the event of such a disaster, the rescue workers (fire, medical, police, military, etc.) would need to communicate to-and-fro a central command centre itermittently. In addition, we imagine a second network provider whose infrastructure is affected by the disaster and their UEs are to be accommodated over another provider's network. We consder these as our 'secondary users' and make the following assumption: the secondary users only need an network connection good enough to do web browsing or accessing social media apps in times of such emergency.

So, we do three set of experiments to evaluate the impact on primary users when rescue workers and secondary workers are accommodated on the network, using slicing. In the first experiment, we have only one slice (named 'primary') with 100% resource share and primary UE(s) are bounded to this slice. In the second experiment, we create another slice (named 'rescue') and allot a resource share ratio of 80:20 for the primary:rescue slices. Only the UE(s) of the rescue workers is bounded to the 'rescue' slice. In the third experiment, we keep the first two slices and their UEs as it is and add the secondary UE(s), unbounded to any slice. 

|           <br>UE          |            <br>Experiment 1            |            <br>Experiment 2           |            <br>Experiment 3           |
|:-------------------------:|:--------------------------------------:|:-------------------------------------:|:-------------------------------------:|
|     <br>Primary UE(s)     |    <br>‘Primary’ slice (100% share)    |    <br>‘Primary’ slice (80% share)    |    <br>‘Primary’ slice (80% share)    |
|     <br>Rescue Workers    |             <br>Don’t exist            |     <br>‘Rescue’ slice (20% share)    |     <br>‘Rescue’ slice (20% share)    |
|    <br>Secondary UE(s)    |             <br>Don’t exist            |            <br>Don’t exist            |       <br>Unbounded to any slice      |


For emulating the network traffic patterns of the various applications described above, we use the following methods:

- Video-on-Demand: Setup Apache Web Server, ran video client on downloaded videos and observed video rate and instances of rebuffering from logs
- Video Streaming: 2Mbps downlink UDP iperf stream, observing packet loss and jitter
- Video Calling: 1.5Mbps bidirectional UDP iperf stream, observing packet loss and jitter
- Web Browsing: Setup Apache Web Server, mirrored some selected websites like reddit.com , nytimes.com etc., in each iteration of a loop I retrieved a randomly chosen websiteby wget, then waited for random time interval (between 10s and 30s) and then re-ran the loop. Metrics observed are time taken to retrieve each website.
- Intermittent Data transfer (for rescue workers): in each iteration of a loop, I setup a iperf TCP stream to send randomly chosen amount of data (between 0.5MB and 30MB) in a random direction (uplink or downlink), then waited for a random time interval (between 10s and 30s) and then re-ran the loop. Metrics observed are loss and time taken.    

<!-- ## Results

In the first experiment, primary users alone are allocated 100% of the network resources. 

**TODO - table here**

We observe that... **TODO**

In the second experiment, primary users share the network with emergency workers. 

**TODO - table here**

We observe that... **TODO**

In the third experiment, primary users share the network with emergency workers, and users that are not subscribed to this service provider may also use excess resources.

**TODO - table here**

We observe that... **TODO**
-->

## 2.0 Run my experiment
In order to run the experiments, as described above, follow the steps described in this section. You will need several simultaneous live SSH shell connections to the POWDER Node. For this you have three options: (1) a local `bash` shell and SSH using the SSH public key you uploaded to POWDER; (2) click on the node in Topology View in your Powder Experiment and select `Open VNC Window`. Once a new VNC window is opened, click anywhere on the screen and then select `XTerm` option in the pop-up menu. This will open a new terminal window on the remote node; (3) in-browser POWDER shell support. The least cumbersome to use is the first option. 

### 2.1 Instantiate a POWDER profile

In your browser, login to POWDER testbed ( a cloudlab login works fine) and then browse to [O-RAN profile](https://www.powderwireless.net/show-profile.php?project=PowderProfiles&profile=O-RAN). Click on the 'Instantiate' button. It will open a page where you can change the various parameters of the profile. For our experiments, we only need the default set of parameters - so, do not change any parameters and click on 'Next'. After that you need to select the Project you are added to and can optionally give your exeriment a name (or else POWDER will allot it a randomly generated name). Then, click on 'Next' and 'Finish' on the final page. 

_Note 1:_ If you want to play around with the parameters, beware as not all combinations work - O-RAN is under heavy development. <br>
_Note 2:_ You can also schedule the initalization of an experiment at a future date and time by using the options on the final page.

### 2.2 Install and configure additional software and files

After you setup a new SSH connection to the node, run the following commands to install the required softwares:

1. Install GNU Radio (will be used to run a flowgraph)
```
sudo apt install gnuradio
```
Check if it is succesfully installed using `gnuradio-config-info --version`

2. Install and setup Apache Web server (will be used to run the emulated video-on-demand and web browsing applications)
```
sudo apt update  
sudo apt install -y apache2
```
Check if it is succesfully installed using `apache2 -v #to check`

3. Change port of Apache Web Server and restart (The default port 80 is not available as it used by the Kubernetes clusters)
```
sudo vi /etc/apache2/ports.conf
```
This shall open in vim the `ports.conf` file. In this file, identify the line which reads `Listen 80`, edit it to `Listen 5010` and save and exit the file. 
After changing the port in the config file, restart the Apache Web Server with this command:
```
sudo service apache2 restart
```

4. Download the required videos for video-on-demand application emulation
```
wget https://nyu.box.com/shared/static/d6btpwf5lqmkqh53b52ynhmfthh2qtby.tgz -O media.tgz
```
Shift the downloaded videos in the web server directory
```
sudo tar -v -xzf media.tgz -C /var/www/html/
```

5. Install Python2 (will be used for video-on-demand application emulation)
```
sudo apt update  
sudo apt install -y python2
```

6. Download and save the file `flowgraph.py` in this repo, on your local computer. And then transfer the file to the remote node, using scp:
   ```
   scp <path_to_local_file> <address_of_remote_node>:flowgraph.py
   ```
   The flowgraph is a Python file made using GNU Radio Companion software that directs the signals from various ports in required directions. It consists of source blocks (representing `tx_ports` of the UEs and the eNb), sink blocks (representing `rx_ports` of the UEs and the eNb), multiply constant blocks (that multiplies the signal with a set gain/attenuation) and connections between these blocks (so that a single eNb can connect to multiple UEs).

### 2.3 Make sure the experiment is setup
After initializing the experiment, it takes about 20-30 minutes for all the setup scripts to run and complete the setup of the experiment. To check if the setup has been completed, ensure the following:
1. When your startup scripts are running, on the experiment page, it will say `Startup scripts are still running`. Refresh the experiment page on browser and see if it still says so.
2. Check the logs by running `tail -F /local/logs/setup.log` on a SSH-ed connection to the node
3. Check if all deployments are 'Available' by running this command on a SSH-ed connection to the node
   ```
   kubectl -n ricplt get deployments
   ```
4. Check if all the pods are 'Running' by running this command on a SSH-ed connection to the node
   ```
   kubectl -n ricplt get pods
   ```
5. Finally, wait until the following command returns a non-error
   ```
   kubectl -n ricplt wait pod --for=condition=Ready --all --timeout=3m
   ```
Once, all the deployments and pods are working fine, we are all set to start initializing our RAN components. 

### 2.4 Adding more UEs to the user database 
By default the profile is setup for having only one UE connected to one eNodeB. But for our experiment, we want to connect multiple UEs to the single eNodeB. Hence, we need to make the following changes:

In a SSH connection to the POWDER node, run the following commands to edit the `user_db.csv` file (containing database of all UEs for the core network)
   ```
   sudo sed -ie 's/^\(ue2.*\),dynamic/\1,192.168.0.3/' /etc/srslte/user_db.csv
   sudo sed -i 's/mil/xor/' /etc/srslte/user_db.csv
   echo "ue3,xor,001010123456781,00112233445566778899aabbccddeeff,opc,63bfa50ee6523365ff14c1f45f88737d,8002,000000001488,7,192.168.0.4" | sudo tee -a /etc/srslte/user_db.csv
   ```
To manually read the edited file and check if all three UEs are successfully added with their respective IMSI numbers and IP adddresses, run `cat /etc/srslte/user_db.csv`.

_Note 1:_ If you want to extend the experiment to more than 3 UEs, then add more lines similar to the ue3 line above (with a unique IMSI number and IP address). However, note that the flowgraph will also need to be edited accordingly to handle more UE ports. 

### 2.5 Start EPC and eNodeB
In a new SSH connection to the POWDER node, 
1. Start the EPC (Core)
  ```
  sudo /local/setup/srslte-ric/build/srsepc/src/srsepc --spgw.sgi_if_addr=192.168.0.1 2>&1 >> /local/logs/srsepc.log &
  ```
To check if the epc has been initialized succesfully, read the logs using `cat /local/logs/srsepc.log`

2. Setup the eNodeB
```
. /local/repository/demo/get-env.sh #setup local variables
sudo /local/setup/srslte-ric/build/srsenb/src/srsenb --enb.n_prb=15 --enb.name=enb1 --enb.enb_id=0x19B --rf.device_name=zmq --rf.device_args="fail_on_disconnect=true,id=enb,base_srate=23.04e6,tx_port=tcp://*:2000,rx_port=tcp://localhost:2001" --ric.agent.remote_ipv4_addr=${E2TERM_SCTP} --ric.agent.local_ipv4_addr=10.10.1.1 --ric.agent.local_port=52525 --log.all_level=warn --ric.agent.log_level=debug --log.filename=stdout --slicer.enable=1 --slicer.workshare=1
```
_Note 1:_ If `slicer.workshare` argument for srsenb is 1, then work-conserving mode is enabled (default). If you want to disable work-conserving mode, then make the argument value 0 instead of 1. <br>
_Note 2:_ The first srsenb argument `enb.n_prb` changes the available PRBs. Since absolute RAN performance is not relevant to our experiment, the value is arbitrarily chosen to be 15.

### 2.6 Start UEs and GNU Radio Broker
 1. First, we create separate namespaces for each of the UEs since SPGW network interface from the EPC process is already in the root network namespace. In a SSH-connection to the node, run:
    ```
    sudo ip netns add ue1
    sudo ip netns add ue2
    sudo ip netns add ue3
    ```
2. In separate SSH-connections for each UE, start the UE as follows:
   ```
   sudo /local/setup/srslte-ric/build/srsue/src/srsue --rf.device_name=zmq --rf.device_args="tx_port=tcp://*:2002,rx_port=tcp://localhost:2052,id=ue1,base_srate=23.04e6" --usim.algo=xor --usim.imsi=001010123456789 --usim.k=00112233445566778899aabbccddeeff --usim.imei=353490069873310 --log.all_level=warn --log.filename=stdout --gw.netns=ue1
   ```
   In a separate SSH-connection,
   ```
   sudo /local/setup/srslte-ric/build/srsue/src/srsue --rf.device_name=zmq --rf.device_args="tx_port=tcp://*:2004,rx_port=tcp://localhost:2054,id=ue2,base_srate=23.04e6" --usim.algo=xor --usim.imsi=001010123456780 --usim.k=00112233445566778899aabbccddeeff --usim.imei=353490069873310 --log.all_level=warn --log.filename=stdout --gw.netns=ue2
   ```
   In a separate SSH-connection
   ```
   sudo /local/setup/srslte-ric/build/srsue/src/srsue --rf.device_name=zmq --rf.device_args="tx_port=tcp://*:2003,rx_port=tcp://localhost:2053,id=ue3,base_srate=23.04e6" --usim.algo=xor --usim.imsi=001010123456781 --usim.k=00112233445566778899aabbccddeeff --usim.imei=353490069873310 --log.all_level=warn --log.filename=stdout --gw.netns=ue3
   ```
Note that the IMSI and key values correspond to the values of the respective UEs entered in the `user_db`. Moreover, the `tx_port` and `rx_port` correspond to the ports in the GNU Radio flowgraph.

3. After all three UEs have been initialized, start the GNU Radio companion flowgraph in a separate SSH-connection to the node:
   ```
   python3 flowgraph.py
   ```

### 2.7 Deploy NexRAN xApp for slicing
In a new SSH connection to the node, 
1. Onboard the xApp
```
/local/setup/oran/dms_cli onboard /local/profile-public/nexran-config-file.json /local/setup/oran/xapp-embedded-schema.json
```
2. Verify that the xApp is successfully created. On running this command, you should see a JSON blob that refers to a Helm chart
```
/local/setup/oran/dms_cli get_charts_list
```
3. Deploy the xApp
```
/local/setup/oran/dms_cli install --xapp_chart_name=nexran --version=0.1.0 --namespace=ricxapp
```
4. (optional) if you want to view the logs of the xApp, run this command:
```
kubectl logs -f -n ricxapp -l app=ricxapp-nexran
```
### 2.8 Video Streaming on UE1

### 2.9 Video Calling on UE1

### 2.10 Video-on-demand on UE1

### 2.11 Web Browsing on UE1

### 2.12 API Calls to xApp

### 2.13 Adding Rescue Workers

### 2.14 Adding Secondary Workers

<!--
### First experiment: Only primary users

#### Assign UE to primary slice

#### Start traffic on primary slice

#### Analyze results from the first experiment

### Second experiment: Primary and secondary users

#### Assign UE to secondary slice

#### Start traffic on primary slice and secondary slice

#### Analyze results from the second experiment

### Third experiment: Primary, secondary, and unattached users

#### Start traffic on primary slice and secondary slice, and on unattached UE

#### Analyze results from the third experiment
-->

## 3.0 Troubleshooting

1. Cannot find the 'Instantiate' button when you open the profile link.
This is most likely because you are not logged into Powder. You should be able to see the 'Instantiate' button only when you are logged into POWDER.

3. 

### References


