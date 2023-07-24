This experiment... **TODO**

It will take about 60-120 minutes to run this experiment.

To run this experiment, you will need an account on the [POWDER testbed](https://powderwireless.net/). (If you have used CloudLab, you may already have a POWDER account!) You will also need to be part of an active project and have SSH keys associated with your account.

## Background

When cellular networks are affected by natural disaster, resource sharing among providers can mitigate impact on users and emergency workers....  **TODO**

But before opening their networks to non-subscribers, providers want reassurance that their own subscribers will not be unduly affected...  **TODO**

In this experiment, we emulate a disaster recovery scenario on POWDER using network slicing in O-RAN, to serve as a proof of concept for network sharing in disaster recovery and to support further research in the area.

### Emulating a cellular network on POWDER

 **TODO**

### Network slicing with O-RAN on POWDER

  **TODO** 

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


