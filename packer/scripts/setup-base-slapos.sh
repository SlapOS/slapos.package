#!/bin/bash

set -e

aptitude -y install --without-recommends python-setuptools

wget https://bootstrap.pypa.io/get-pip.py
python get-pip.py

pip2 install --exists-action=i six
pip2 install --exists-action=i requests
pip2 install --exists-action=i slapcache

wget http://deploy.erp5.net/vifib-base -O /root/run-vifib-base
RE6STTOKEN=$re6st_token 
COMPUTERTOKEN=$computer_token 
COMPUTERNAME=$computer_name

bash /root/run-vifib-base 

re6st-conf --registry http://re6stnet.gnet.erp5.cn/ --token $RE6STTOKEN -r title $RE6STTOKEN -d /etc/re6stnet

slapos node register --token $COMPUTERTOKEN  --interface-name lo $COMPUTERNAME

# Re-run after the register to finish up the configuration
bash /root/run-vifib-base 
