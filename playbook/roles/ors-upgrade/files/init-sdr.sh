#!/bin/bash

AMARISOFT_PATH="/opt/amarisoft/$(ls -1 /opt/amarisoft | grep "^v[0-9]\{4\}-[0-9]\{2\}-[0-9]\{2\}$" | sort | tail -n1)"

$AMARISOFT_PATH/trx_sdr/sdr_util version && exit;
lsmod | grep -q sdr || rmmod sdr;
cd $AMARISOFT_PATH/trx_sdr/kernel;
make clean;
bash init.sh;
$AMARISOFT_PATH/enb/lte_init.sh;
