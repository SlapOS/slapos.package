
wget http://deploy.erp5.net/erp5-standalone -O /root/run-standalone
bash /root/run-standalone

sleep 10

for i in 1 2 3 4 5
do
  slapos node software 
  sleep 5
done


for i in 1 2 3 4 5
do
  slapos node instance
  sleep 5
done


