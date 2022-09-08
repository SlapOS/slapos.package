cd /root/trx_sdr/kernel;
make clean;
bash init.sh 2>> /opt/amarisoft/init-sdr.log >> /opt/amarisoft/init-sdr.log
$(find /opt/amarisoft -type f -wholename "*v*/*lteenb*/*lte_init.sh*") 2>> /opt/amarisoft/init-sdr.log >> /opt/amarisoft/init-sdr.log
