#!/bin/bash
### This script is used for run load on mongodb pod
### eg. sh run-workload-mongodb.sh

nameSpace=$1
mongodbPodName=$2
ycsbPodName=$3
mongodbIP=$4

threads=10
recordCount=1000
operationCount=1000
iterations=10

outputFile=output-mongodb-pod-$ycsbPodName-threads-$threads-recordCount-$recordCount-operationCount-$operationCount.$$

G='\033[1;32m'
N='\033[0m'

for i in $(seq 1 $iterations); do
    echo -e "\n------ Running iteration $i ------" | tee -a $outputFile
    ### delete database
    echo -e "\n${G}Deleting Database${N}"
    echo -e "\n****** Deleting existing database ******" >> $outputFile
    (time oc -n $nameSpace exec -i $mongodbPodName -- bash -c \
        "scl enable rh-mongodb32 -- mongo -u redhat -p redhat $mongodbIP:27017/sampledb --eval 'db.usertable.remove({})'") 2>&1 |& tee -a $outputFile

    ### load or create database
    echo -e "\n${G}Loading Database${N}"
    echo -e "\n****** Loading database ******" >> $outputFile
    (time oc -n $nameSpace exec -i $ycsbPodName -- bash -c \
        "./bin/ycsb load mongodb -s -threads $threads -P "workloads/workloadf" -p mongodb.url=mongodb://redhat:redhat@$mongodbIP:27017/sampledb -p recordcount=$recordCount \
        -p operationcount=$operationCount") 2>&1 |& tee -a $outputFile

    ### run or updating database
    echo -e "\n${G}Updating Database${N}"
    echo -e "\n****** Updating database ******" >> $outputFile
    (time oc -n $nameSpace exec -i $ycsbPodName -- bash -c \
        "./bin/ycsb run mongodb -s -threads $threads -P "workloads/workloadf" -p mongodb.url=mongodb://redhat:redhat@$mongodbIP:27017/sampledb -p recordcount=$recordCount \
        -p operationcount=$operationCount") 2>&1 |& tee -a $outputFile
done