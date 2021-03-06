#!/bin/bash

echo "####################################################"
echo "# Random Write with fio randwrite   "
echo "####################################################"
rm -f test
fio --randrepeat=1 --ioengine=libaio --direct=1 --gtod_reduce=1 --name=test --filename=test --bs=4k --iodepth=64 --size=4G --readwrite=randwrite

echo "####################################################"
echo "# Random Write with fio randwrite (numjobs=2)   "
echo "####################################################"
rm -f test
fio --randrepeat=1 --ioengine=libaio --numjobs=2 --direct=1 --gtod_reduce=1 --name=test --filename=test --bs=4k --iodepth=64 --size=4G --readwrite=randwrite

echo "####################################################"
echo "# Random Read with fio randread"
echo "####################################################"
rm -f test
fio --randrepeat=1 --ioengine=libaio --direct=1 --gtod_reduce=1 --name=test --filename=test --bs=4k --iodepth=64 --size=4G --readwrite=randread

echo "####################################################"
echo "# Random Read with fio randread (numjobs=2)"
echo "####################################################"
rm -f test
fio --randrepeat=1 --ioengine=libaio --numjobs=2 --direct=1 --gtod_reduce=1 --name=test --filename=test --bs=4k --iodepth=64 --size=4G --readwrite=randread


echo "####################################################"
echo "# Read with fio read"
echo "####################################################"
rm -f test
fio --randrepeat=1 --ioengine=libaio --direct=1 --gtod_reduce=1 --name=test --filename=test --bs=4k --iodepth=64 --size=4G --readwrite=read


echo "####################################################"
echo "# Read with fio read (numjobs=2)"
echo "####################################################"
rm -f test
fio --randrepeat=1 --ioengine=libaio --numjobs=2 --direct=1 --gtod_reduce=1 --name=test --filename=test --bs=4k --iodepth=64 --size=4G --readwrite=read

echo "####################################################"
echo "# Write with fio write"
echo "####################################################"
rm -f test
fio --randrepeat=1 --ioengine=libaio --direct=1 --gtod_reduce=1 --name=test --filename=test --bs=4k --iodepth=64 --size=4G --readwrite=write

echo "####################################################"
echo "# Write with fio write (numjobs=2)"
echo "####################################################"
rm -f test
fio --randrepeat=1 --ioengine=libaio --numjobs=2 --direct=1 --gtod_reduce=1 --name=test --filename=test --bs=4k --iodepth=64 --size=4G --readwrite=write

echo "####################################################"
echo "# Write with dd "
echo "####################################################"
rm -f /test
time sh -c "dd if=/dev/zero of=/test bs=4k count=2000000 conv=fsync && sync"

echo "####################################################"
echo "# Read with dd"
echo "####################################################"
time sh -c "dd if=/test of=/dev/null"

echo "####################################################"
echo "# Test with bonnie++                                "
echo "####################################################"
bonnie++ -d / -n 0 -m TEST -f -b -u root
