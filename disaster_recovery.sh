#Open Grafana dashboard

##CHECKUP
kubectl -n ricplt wait pod --for=condition=Ready --all --timeout=3m #Wait until all RIC services are back up
# To check if our near-RT RIC is up
kubectl -n ricplt get deployments #All deployments should be Available
kubectl -n ricplt get pods #all pods should be running 

##Install GNU Radio
sudo apt install gnuradio
gnuradio-config-info --version #check version (grc_version: 3.10.4.0)

## Setup Apache Server
sudo apt update  
sudo apt install -y apache2
apache2 -v #to check

sudo vi /etc/apache2/ports.conf
vim /etc/apache2/ports.conf
# Edit line "Listen 80" to "Listen 5010"
#exit vim with :wq!
sudo service apache2 restart

## Download Video (for on demand)
wget https://nyu.box.com/shared/static/d6btpwf5lqmkqh53b52ynhmfthh2qtby.tgz -O media.tgz
sudo tar -v -xzf media.tgz -C /var/www/html/

## Change user_db 
sudo sed -ie 's/^\(ue2.*\),dynamic/\1,192.168.0.3/' /etc/srslte/user_db.csv
sudo sed -i 's/mil/xor/' /etc/srslte/user_db.csv
echo "ue3,xor,001010123456781,00112233445566778899aabbccddeeff,opc,63bfa50ee6523365ff14c1f45f88737d,8002,000000001488,7,192.168.0.4" | sudo tee -a /etc/srslte/user_db.csv
echo "ue4,xor,001010123456782,00112233445566778899aabbccddeeff,opc,63bfa50ee6523365ff14c1f45f88737d,8002,000000001488,7,192.168.0.5" | sudo tee -a /etc/srslte/user_db.csv
echo "ue5,xor,001010123456783,00112233445566778899aabbccddeeff,opc,63bfa50ee6523365ff14c1f45f88737d,8002,000000001488,7,192.168.0.6" | sudo tee -a /etc/srslte/user_db.csv
echo "ue6,xor,001010123456784,00112233445566778899aabbccddeeff,opc,63bfa50ee6523365ff14c1f45f88737d,8002,000000001488,7,192.168.0.7" | sudo tee -a /etc/srslte/user_db.csv
cat /etc/srslte/user_db.csv #check

## Setup EPC (NEW SSH)
sudo /local/setup/srslte-ric/build/srsepc/src/srsepc --spgw.sgi_if_addr=192.168.0.1 2>&1 >> /local/logs/srsepc.log & #run a srsLTE EPC
cat /local/logs/srsepc.log #check

## Setup eNodeB 
. /local/repository/demo/get-env.sh #setting local variables
#slice-workshare = 0(work-conserving disabled)/1(work-conserving enabled) 
sudo /local/setup/srslte-ric/build/srsenb/src/srsenb --enb.n_prb=15 --enb.name=enb1 --enb.enb_id=0x19B --rf.device_name=zmq --rf.device_args="fail_on_disconnect=true,id=enb,base_srate=23.04e6,tx_port=tcp://*:2000,rx_port=tcp://localhost:2001" --ric.agent.remote_ipv4_addr=${E2TERM_SCTP} --ric.agent.local_ipv4_addr=10.10.1.1 --ric.agent.local_port=52525 --log.all_level=warn --ric.agent.log_level=debug --log.filename=stdout --slicer.enable=1 --slicer.workshare=1

##Make UE namespaces
sudo ip netns add ue1
sudo ip netns add ue2 
sudo ip netns add ue3
sudo ip netns add ue4
sudo ip netns add ue5
sudo ip netns add ue6 

#run UEs
sudo /local/setup/srslte-ric/build/srsue/src/srsue --rf.device_name=zmq --rf.device_args="tx_port=tcp://*:2002,rx_port=tcp://localhost:2052,id=ue1,base_srate=23.04e6" --usim.algo=xor --usim.imsi=001010123456789 --usim.k=00112233445566778899aabbccddeeff --usim.imei=353490069873310 --log.all_level=warn --log.filename=stdout --gw.netns=ue1
sudo /local/setup/srslte-ric/build/srsue/src/srsue --rf.device_name=zmq --rf.device_args="tx_port=tcp://*:2004,rx_port=tcp://localhost:2054,id=ue2,base_srate=23.04e6" --usim.algo=xor --usim.imsi=001010123456780 --usim.k=00112233445566778899aabbccddeeff --usim.imei=353490069873310 --log.all_level=warn --log.filename=stdout --gw.netns=ue2
sudo /local/setup/srslte-ric/build/srsue/src/srsue --rf.device_name=zmq --rf.device_args="tx_port=tcp://*:2003,rx_port=tcp://localhost:2053,id=ue3,base_srate=23.04e6" --usim.algo=xor --usim.imsi=001010123456781 --usim.k=00112233445566778899aabbccddeeff --usim.imei=353490069873310 --log.all_level=warn --log.filename=stdout --gw.netns=ue3
sudo /local/setup/srslte-ric/build/srsue/src/srsue --rf.device_name=zmq --rf.device_args="tx_port=tcp://*:2005,rx_port=tcp://localhost:2055,id=ue4,base_srate=23.04e6" --usim.algo=xor --usim.imsi=001010123456782 --usim.k=00112233445566778899aabbccddeeff --usim.imei=353490069873310 --log.all_level=warn --log.filename=stdout --gw.netns=ue4
#secondary scenarios
sudo /local/setup/srslte-ric/build/srsue/src/srsue --rf.device_name=zmq --rf.device_args="tx_port=tcp://*:2006,rx_port=tcp://localhost:2056,id=ue5,base_srate=23.04e6" --usim.algo=xor --usim.imsi=001010123456783 --usim.k=00112233445566778899aabbccddeeff --usim.imei=353490069873310 --log.all_level=warn --log.filename=stdout --gw.netns=ue5
sudo /local/setup/srslte-ric/build/srsue/src/srsue --rf.device_name=zmq --rf.device_args="tx_port=tcp://*:2007,rx_port=tcp://localhost:2057,id=ue6,base_srate=23.04e6" --usim.algo=xor --usim.imsi=001010123456784 --usim.k=00112233445566778899aabbccddeeff --usim.imei=353490069873310 --log.all_level=warn --log.filename=stdout --gw.netns=ue6

## Run the GNU Radio Companion Flowgraph
scp top_block_5ue.py sethia@pc834.emulab.net:flow.py
#after SSHing
python3 flow.py

## ONBOARD & DEPLOY NexRAN xApp (NEW SSH)
/local/setup/oran/dms_cli onboard /local/profile-public/nexran-config-file.json /local/setup/oran/xapp-embedded-schema.json #Onboard nexran xapp
/local/setup/oran/dms_cli get_charts_list #verify the app is successfully created
/local/setup/oran/dms_cli install --xapp_chart_name=nexran --version=0.1.0 --namespace=ricxapp #deploy the nexran xapp
kubectl logs -f -n ricxapp -l app=ricxapp-nexran #view logs of nexran xApp

##5. DEMO SCRIPT (NEW SSH)
. /local/repository/demo/get-env.sh #collecting IP address of nexran northbound RESTful interface
#to check that we can talk to the nexran xApp (should output some version/build info)
curl -i -X GET http://${NEXRAN_XAPP}:8000/v1/version ; echo ; echo 
#configure Grafana Dashboard
curl -L -X PUT http://$NEXRAN_XAPP:8000/v1/appconfig -H "Content-type: application/json" -d '{"kpm_interval_index":18,"influxdb_url":"'$INFLUXDB_URL'?db=nexran"}'


## Video Streaming on UE1
iperf3 -s -B 192.168.0.1 -p 5009 -i 1
sudo ip netns exec ue1 iperf3 -c 192.168.0.1 -p 5009 -i 1 -t 36000 -b 2M -u -R

## Zoom Call on UE2
iperf3 -s -B 192.168.0.1 -p 5008 -i 1
sudo ip netns exec ue2 iperf3 -c 192.168.0.1 -p 5008 -i 1 -t 36000 -b 1.5M -u --bidir

## Video on Demand on UE3
# install Python2
sudo apt update  
sudo apt install -y python2  
# get the client
git clone https://github.com/pari685/AStream  
sudo ip netns exec ue3 python2 AStream/dist/client/dash_client.py -m http://192.168.0.1:5010/media/BigBuckBunny/4sec/BigBuckBunny_4s.mpd -p 'basic' -d 
#could also use policy 'netflix' instead of 'basic'
#Shift log files ASTREAM_LOGS to local computer
scp sethia@pc<no>.emulab.net:ASTREAM_LOGS D:\Interns\NYU\Research\video_stream_logs

## Web Browsing on UE4
cd /var/www/html/ 
sudo wget -e robots=off --wait 1 -H -p -k http://engineering.nyu.edu/  
sudo wget -e robots=off --wait 1 -H -p -k http://linkedin.com/  
sudo wget -e robots=off --wait 1 -H -p -k http://reddit.com/  
sudo wget -e robots=off --wait 1 -H -p -k http://twitter.com/

scp web_browsing.py sethia@pc<no.>.emulab.net:webue4.py
#After SSH
python3 webue4.py
#shift csv files to local computer
scp sethia@pc<no>.emulab.net:ue4_browsing_data.csv D:\Interns\NYU\Research\video_stream_logs

### OPTIONAL SCENARIOS
## Sporadic data transmission on UE5
iperf3 -s -B 192.168.0.1 -p 5011 -i 1
#sudo ip netns exec ue1 iperf3 -c 192.168.0.1 -p 5010 -i 1 -t 36000 -R
scp emergency_workers.py sethia@pc<no>.emulab.net:emergency.py
##after ssh
#sudo ip netns exec ue1 python3 emergency.py
python3 emergency.py
#shif csv files to local computer
scp sethia@pc<no>.emulab.net:ue5_rescue_data.csv D:\Interns\NYU\Research\video_stream_logs


######### COMMANDS FOR XAPP
#scp run-nexran-slicing-3ue.sh sethia@pc834.emulab.net:3ue.sh
export NEXRAN_XAPP=`kubectl get svc -n ricxapp --field-selector metadata.name=service-ricxapp-nexran-nbi -o jsonpath='{.items[0].spec.clusterIP}'`
echo NEXRAN_XAPP=$NEXRAN_XAPP ; echo
#listing enodeb
OUTPUT=`curl -X POST -H "Content-type: application/json" -d '{"type":"eNB","id":411,"mcc":"001","mnc":"01"}' http://${NEXRAN_XAPP}:8000/v1/nodebs`
echo $OUTPUT
NBNAME=`echo $OUTPUT | jq -r '.name'`
#creating fast slice
curl -i -X POST -H "Content-type: application/json" -d '{"name":"fast","allocation_policy":{"type":"proportional","share":1024}}' http://${NEXRAN_XAPP}:8000/v1/slices ; echo ; echo
#creating slow slice
curl -i -X POST -H "Content-type: application/json" -d '{"name":"slow","allocation_policy":{"type":"proportional","share":256}}' http://${NEXRAN_XAPP}:8000/v1/slices ; echo ; echo
#binding slices to enodeb
curl -i -X POST http://${NEXRAN_XAPP}:8000/v1/nodebs/${NBNAME}/slices/fast ; echo ; echo
curl -i -X POST http://${NEXRAN_XAPP}:8000/v1/nodebs/${NBNAME}/slices/slow ; echo ; echo
#creating UE1 and UE2
curl -i -X POST -H "Content-type: application/json" -d '{"imsi":"001010123456789"}' http://${NEXRAN_XAPP}:8000/v1/ues ; echo ; echo
curl -i -X POST -H "Content-type: application/json" -d '{"imsi":"001010123456780"}' http://${NEXRAN_XAPP}:8000/v1/ues ; echo ; echo
curl -i -X POST -H "Content-type: application/json" -d '{"imsi":"001010123456781"}' http://${NEXRAN_XAPP}:8000/v1/ues ; echo ; echo
curl -i -X POST -H "Content-type: application/json" -d '{"imsi":"001010123456782"}' http://${NEXRAN_XAPP}:8000/v1/ues ; echo ; echo
#optional scenarios
curl -i -X POST -H "Content-type: application/json" -d '{"imsi":"001010123456783"}' http://${NEXRAN_XAPP}:8000/v1/ues ; echo ; echo
curl -i -X POST -H "Content-type: application/json" -d '{"imsi":"001010123456784"}' http://${NEXRAN_XAPP}:8000/v1/ues ; echo ; echo

#binding UE1-4 to fast slice
curl -i -X POST http://${NEXRAN_XAPP}:8000/v1/slices/fast/ues/001010123456789 ; echo ; echo
curl -i -X POST http://${NEXRAN_XAPP}:8000/v1/slices/fast/ues/001010123456780 ; echo ; echo
curl -i -X POST http://${NEXRAN_XAPP}:8000/v1/slices/fast/ues/001010123456781 ; echo ; echo
curl -i -X POST http://${NEXRAN_XAPP}:8000/v1/slices/fast/ues/001010123456782 ; echo ; echo

#binding UE5 to slow slice
curl -i -X POST http://${NEXRAN_XAPP}:8000/v1/slices/slow/ues/001010123456783 ; echo ; echo


###############
## CLEANUP
sudo pkill srsue #interrupt srsue process
sudo pkill srsenb #interrupt srsenb process
sudo pkill srsepc #interrupt srsepc process
/local/repository/demo/cleanup-nexran.sh #unconfigure existing NexRAN xApp instance
. /local/repository/demo/get-env.sh #setting local variables for various RIC service endpoints
curl -L -X DELETE http://${APPMGR_HTTP}:8080/ric/v1/xapps/nexran #remove the existing nexRAN xApp
# restart core RIC Components
kubectl -n ricplt rollout restart  deployments/deployment-ricplt-e2term-alpha deployments/deployment-ricplt-e2mgr deployments/deployment-ricplt-submgr deployments/deployment-ricplt-rtmgr deployments/deployment-ricplt-appmgr statefulsets/statefulset-ricplt-dbaas-server
######################



##WAIT
#Make slices auto-equalizing
. /local/repository/demo/get-env.sh
curl -i -X PUT -H "Content-type: application/json" -d '{"allocation_policy":{"type":"proportional","share":256,"auto_equalize":true}}' http://${NEXRAN_XAPP}:8000/v1/slices/slow ; echo ; echo ;
curl -i -X PUT -H "Content-type: application/json" -d '{"allocation_policy":{"type":"proportional","share":1024,"auto_equalize":true}}' http://${NEXRAN_XAPP}:8000/v1/slices/fast ; echo ; echo ;


## 5b. Invert priority of fast and slow slices
. /local/repository/demo/get-env.sh
curl -i -X PUT -H "Content-type: application/json" -d '{"allocation_policy":{"type":"proportional","share":1024}}' http://${NEXRAN_XAPP}:8000/v1/slices/slow ; echo ; echo ;
curl -i -X PUT -H "Content-type: application/json" -d '{"allocation_policy":{"type":"proportional","share":256}}' http://${NEXRAN_XAPP}:8000/v1/slices/fast ; echo ; echo
#Observe: client bandwidth drop to further 7Mbps

##5c. Equalize priority of fast slice to match the modified slow slice
curl -i -X PUT -H "Content-type: application/json" -d '{"allocation_policy":{"type":"proportional","share":1024}}' http://${NEXRAN_XAPP}:8000/v1/slices/fast ; echo ; echo
#Observe: client bandwidith increase to around 18Mbps

##5d. NexRAN Slice Throttling Demo
/local/repository/demo/cleanup-nexran.sh #cleanup to ensure no lingering nexRan state
# (if NodeB or UEs have crashed, restart them)

#creates two slices, fast and slow, where fast is given a proportional share of 512 (the max, range is 1-1024), and slow is given a share of 256.
/local/repository/demo/run-nexran-throttle.sh 
# Observe: effect of closed-loop control algo adjusting slice shares as downlink utilization theshold is hit and throttling commences
#, share of fast slice drops from 512 to just above 120 in a repeating pattern
#, similarly see bytes transmitted in the downlink drop to approx half when throttling is in place

##5e. Change throttling policy
#lengthen throttle_period to 60 seconds
. /local/repository/demo/get-env.sh #get variables
curl -i -X PUT -H "Content-type: application/json" -d '{"allocation_policy":{"type":"proportional","share":512,"auto_equalize":false,"throttle":true,"throttle_threshold":50000000,"throttle_period":60,"throttle_target":5000000}}' http://${NEXRAN_XAPP}:8000/v1/slices/fast ; echo
#Observe: change in Grafana dashboard
curl -i -X PUT -H "Content-type: application/json" -d '{"allocation_policy":{"type":"proportional","share":512,"auto_equalize":false,"throttle":true,"throttle_threshold":5000000,"throttle_period":60,"throttle_target":500000}}' http://${NEXRAN_XAPP}:8000/v1/slices/fast ; echo



##7a. Restart iperf client without -R
# Kill iperf client (^C on Screen 7)
# Restart it without -R option (so as to test the uplink instead of downlink)
sudo ip netns exec ue1 iperf3 -c 192.168.0.1 -p 5010 -i 1 -t 36000

#5f. NexRAN NodeB Uplink masking demo
/local/repository/demo/cleanup-nexran.sh #cleanup to ensure no lingering NexRAN state
#(if NodeB/UEs have crashed, restart them)
#Uplink PRB Masking demo script (creates a single simulated NodeB)
/local/repository/demo/run-zylinium.sh
#Observe: after 10-15s, new mask policy has been installed
#, periodic changes in bandwidth in UE and Slice graphs in Grafana dashboard

#5g. Send another mask schedule to the xApp and NodeB
. /local/repository/demo/get-env.sh # get variables
curl -i -X PUT -H "Content-type: application/json" -d '{"ul_mask_sched":[{"mask":"0x00000f","start":'`echo "import time; print(time.time() + 8)" | python`'},{"mask":"0x000000","start":'`echo "import time; print(time.time() + 28)" | python`'},{"mask":"0x00000f","start":'`echo "import time; print(time.time() + 48)" | python`'},{"mask":"0x000000","start":'`echo "import time; print(time.time() + 68)" | python`'}]}' http://${NEXRAN_XAPP}:8000/v1/nodebs/enB_macro_001_001_00019b




##### Equal Threshold Bullshit
export NEXRAN_XAPP=`kubectl get svc -n ricxapp --field-selector metadata.name=service-ricxapp-nexran-nbi -o jsonpath='{.items[0].spec.clusterIP}'`
curl -i -X POST -H "Content-type: application/json" -d '{"type":"eNB","id":411,"mcc":"001","mnc":"01"}' http://${NEXRAN_XAPP}:8000/v1/nodebs ; echo ; echo ; #creating node
curl -i -X POST -H "Content-type: application/json" -d '{"name":"fast","allocation_policy":{"type":"proportional","share":512,"auto_equalize":true,"throttle":false}}' http://${NEXRAN_XAPP}:8000/v1/slices ; echo ; echo ; #auto equalizing
curl -i -X POST -H "Content-type: application/json" -d '{"name":"slow","allocation_policy":{"type":"proportional","share":256}}' http://${NEXRAN_XAPP}:8000/v1/slices ; echo ; echo ; #auto equalizing


curl -i -X DELETE http://${NEXRAN_XAPP}:8000/v1/slices/fast ; echo ; echo

curl -i -X POST http://${NEXRAN_XAPP}:8000/v1/slices/slow/ues/001010123456780 ; echo ; echo

