# Slicing with O-RAN on Powder Testbed for Disaster Recovery

It will take about 60-120 minutes to run this experiment.

To run this experiment, you will need an account on the [POWDER testbed](https://powderwireless.net/). (If you have used CloudLab, you may already have a POWDER account!) You will also need to be part of an active project and have SSH keys associated with your account.

## Background

Natural disasters like hurricanes or earthquakes often destroy crucial components of the cellular wireless network infrastructure. As a result, all the user equipments (hereafter referred to as UEs) in the affected region cannot connect to the core network. However, sustained cellular connectivity is crucial, especially during a natural disaster as it is used for disseminating important information and alerts to the citizens stuck and for communicating to and by the rescue workers.

For these utilities, resource sharing among network providers can be an effective solution for mitigating impact of the natural disaster. That is if the network infrastructure of a particular provider is affected by the disaster but that of another provider is working fine, then the UEs of the former provider and the UEs of rescue workers can be accommodated on the latter provider's network temporarily to mitigate impact. 

But before opening their networks to non-subscribers, providers are concerned that their own UEs would face either poorer performance or reduced connectivity as the infrastructure can be overwhelmed by the additional non-subscribing users. Hence, it is only natural for the service providers to seek reassurance that their own subscribers will not be unduly affected, if the network resources are shared with other affected providers' UEs and the rescue workers.

For this purpose, slicing may be a useful technique. Slicing allows a network administrator to define multiple virtual networks on the same physical networks. Each of these virtual networks can be optimized for the user equipments deployed on these slices. 

Hence, in this experiment, we emulate a disaster recovery scenario on POWDER testbed. This is done using network slicing in O-RAN. This should serve as a proof of concept for network sharing in disaster recovery and to support further research in the area.

### Emulating a cellular network on POWDER

To emulate a cellular network on POWDER, we initialize an experiment using the O-RAN Profile on POWDER. The [profile](https://www.powderwireless.net/show-profile.php?project=PowderProfiles&profile=O-RAN) deploys an O-RAN instance to connect to RAN resources. It uses a fork of srsLTE. [srsLTE](https://www.srslte.com/) is a free and open-source software suite (developed by Software Radio Systems) that includes: srsUE (User Equipmemt implementation), srsENB (LTE eNodeB implementation), srsEPC (LTE core network implementation) and common libraries for other layers. It has been modified to include O-RAN RIC, E2 support and RAN slicing support in the srsENB. The forked modified source code for srsRAN can be found [here](https://gitlab.flux.utah.edu/powderrenewpublic/srslte-ric).

By default, the profile runs experiments in simulated RAN mode i.e. using emulated links. However, you can also use the profile for live over-the-air testing by making a frequency reservation, initializing one or more experiments containing RAN resources and connecting them to the O-RAN experiment. [This profile](https://www.powderwireless.net/show-profile.php?profile=1bd95656-5b60-11eb-b1eb-e4434b2381fc) is configured to connect to O-RAN experiments - follow the instructions given in the profile for over-the-air testing. But for our experiment's purposes emulated links work just as well and so we will be running only the O-RAN experiment. 

The experiment initializes a single node on the POWDER testbed and we run the eNodeB, core network (EPC) and all the UEs on the same remote hardware. 

### Network slicing with O-RAN on POWDER

For implementation of slicing with O-RAN, we use NexRAN, a top-to-bottom open-source Open-RAN based slicing implementation, presented by [^1]

[^1]: David Johnson, Dustin Maas, and Jacobus Van Der Merwe. 2021. NexRAN: Closed-loop RAN slicing in POWDER -A top-to-bottom open-source open-RAN use case. In Proceedings of the 15th ACM Workshop on Wireless Network Testbeds, Experimental evaluation & CHaracterization (WiNTECH'21). Association for Computing Machinery, New York, NY, USA, 17–23. [https://doi.org/10.1145/3477086.3480842](https://doi.org/10.1145/3477086.3480842)

### Disaster recovery scenario

In this experiment, we imagine a scenario where, in the aftermath of a natural disaster (such as a hurricane), five families are using their cellular network service for their connectivity needs:

* **TODO**

The cellular service provider that these users subscribe to is still operational. In all of our experiments, we consider these our "primary users" and we want to evaluate the extent to which they are affected. 

In the first experiment, the primary users alone are allocated 100% of the network resources. In the second experiment, however, while the majority of the network resource is allocated to the slice that serves the primary users, we also allocate resources in a secondary slice to serve emergency workers:

*  **TODO** 

In the third experiment, the service provider servers primary users and emergency workers in two slices, as described above, and it also permits users of other cellular service providers - that may be in outage due to the disaster - to use any excess resources on its network, without being attached to any slice. These users may be able to use the network to e.g. access emergency information from local government websites.

*  **TODO** 

## Results

In the first experiment, primary users alone are allocated 100% of the network resources. 

**TODO - table here**

We observe that... **TODO**

In the second experiment, primary users share the network with emergency workers. 

**TODO - table here**

We observe that... **TODO**

In the third experiment, primary users share the network with emergency workers, and users that are not subscribed to this service provider may also use excess resources.

**TODO - table here**

We observe that... **TODO**

## Run my experiment

### Instantiate a POWDER profile

**TODO**

### Install additional software

### Set up the cellular network

#### Restart the core RIC components

#### Start EPC and eNB

#### Start UEs and GNU Radio broker

#### Validate connectivity with `ping`

### Deploy network slicing xApp

#### Onboard and deploy xApp

#### Set up two slices

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


## Notes

### References


