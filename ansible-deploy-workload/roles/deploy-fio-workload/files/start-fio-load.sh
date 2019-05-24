#!/bin/bash
### This script is used for run load on FIO pod

nameSpace=$1
fioPodName=$2

fileSize=$3
runTime=$4
ioEngine=$5
direct=$6
fileName=$7

outputFile=output-fio-pod-$fioPodName-filesize-$fileSize-runtime-$runTime-ioengine-$ioEngine.$$

i_index=1
while true;
do
    echo -e "\n------ Running iteration $i_index ------" | tee -a $outputFile
    (time oc -n $nameSpace exec -i $fioPodName -- /bin/ash -c \
        "/usr/local/bin/fio --filesize=$fileSize --runtime=$runTime --ioengine=$ioEngine --direct=$direct --time_based --stonewall --filename=$fileName \
        --name=sw1m@qd32 --description="Bandwidth via 1MB sequential writes @ qd=32" --iodepth=32 --bs=1m --rw=write \
        --name=sr1m@qd32 --description="Bandwidth via 1MB sequential reads @ qd=32" --iodepth=32 --bs=1m --rw=read \
        --name=rw4k@qd1 --description="e2e latency via 4k random writes @ qd=1" --iodepth=1 --bs=4k --rw=randwrite \
        --name=rr4k@qd1 --description="e2e latency via 4k random reads @ qd=1" --iodepth=1 --bs=4k --rw=randread \
        --name=rw4k@qd32 --description="IOPS via 4k random writes @ qd=32" --iodepth=32 --bs=4k --rw=randwrite \
        --name=rr4k@qd32 --description="IOPS via 4k random reads @ qd=32" --iodepth=32 --bs=4k --rw=randread") 2>&1 |& tee -a $outputFile
    i_index=`expr $i_index + 1`
done